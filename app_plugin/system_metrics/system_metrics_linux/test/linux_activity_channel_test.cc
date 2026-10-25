// This exercises the real Flutter Linux SDK without starting a Flutter engine or
// opening a display. The messenger implements Flutter's public transport API;
// values, channels, calls, codec and task replies are the production objects.
#include <flutter_linux/flutter_linux.h>

#include <atomic>
#include <chrono>
#include <iostream>
#include <stdexcept>
#include <string>

// The existing plugin callback intentionally doesn't use its channel parameter.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#include "../linux/system_metrics_plugin.cc"
#pragma GCC diagnostic pop

namespace {
int checks = 0;

void Check(bool condition, const char* message) {
  ++checks;
  if (!condition) throw std::runtime_error(message);
}

typedef struct _TestResponseHandle {
  FlBinaryMessengerResponseHandle parent_instance;
  GBytes* response;
  bool responded;
} TestResponseHandle;

typedef struct {
  FlBinaryMessengerResponseHandleClass parent_class;
} TestResponseHandleClass;

G_DEFINE_TYPE(TestResponseHandle, test_response_handle, fl_binary_messenger_response_handle_get_type())
G_DEFINE_AUTOPTR_CLEANUP_FUNC(TestResponseHandle, g_object_unref)

static void test_response_handle_finalize(GObject* object) {
  auto* self = reinterpret_cast<TestResponseHandle*>(object);
  g_clear_pointer(&self->response, g_bytes_unref);
  G_OBJECT_CLASS(test_response_handle_parent_class)->finalize(object);
}

static void test_response_handle_class_init(TestResponseHandleClass* klass) {
  G_OBJECT_CLASS(klass)->finalize = test_response_handle_finalize;
}

static void test_response_handle_init(TestResponseHandle* self) {
  self->response = nullptr;
  self->responded = false;
}

typedef struct _TestMessenger {
  GObject parent_instance;
  FlBinaryMessengerMessageHandler handler;
  gpointer handler_data;
  GDestroyNotify handler_destroy;
  GThread* main_thread;
  unsigned responses;
} TestMessenger;

typedef struct {
  GObjectClass parent_class;
} TestMessengerClass;

static void test_messenger_interface_init(FlBinaryMessengerInterface* interface);
G_DEFINE_TYPE_WITH_CODE(TestMessenger, test_messenger, G_TYPE_OBJECT,
    G_IMPLEMENT_INTERFACE(fl_binary_messenger_get_type(), test_messenger_interface_init))
G_DEFINE_AUTOPTR_CLEANUP_FUNC(TestMessenger, g_object_unref)

static void set_message_handler(FlBinaryMessenger* messenger, const gchar* channel,
    FlBinaryMessengerMessageHandler handler, gpointer user_data, GDestroyNotify destroy_notify) {
  auto* self = reinterpret_cast<TestMessenger*>(messenger);
  g_assert_cmpstr(channel, ==, "app_system_metrics");
  const auto old_destroy = self->handler_destroy;
  const auto old_data = self->handler_data;
  self->handler = handler;
  self->handler_data = user_data;
  self->handler_destroy = destroy_notify;
  if (old_destroy != nullptr) old_destroy(old_data);
}

static gboolean send_response(FlBinaryMessenger* messenger,
    FlBinaryMessengerResponseHandle* response_handle, GBytes* response, GError**) {
  auto* self = reinterpret_cast<TestMessenger*>(messenger);
  auto* handle = reinterpret_cast<TestResponseHandle*>(response_handle);
  // A worker-thread response or duplicate response is an immediate test failure.
  g_assert_true(g_thread_self() == self->main_thread);
  g_assert_false(handle->responded);
  handle->responded = true;
  handle->response = response == nullptr ? g_bytes_new(nullptr, 0) : g_bytes_ref(response);
  ++self->responses;
  return TRUE;
}

static void test_messenger_interface_init(FlBinaryMessengerInterface* interface) {
  interface->set_message_handler_on_channel = set_message_handler;
  interface->send_response = send_response;
}

static void test_messenger_dispose(GObject* object) {
  auto* self = reinterpret_cast<TestMessenger*>(object);
  set_message_handler(FL_BINARY_MESSENGER(self), "app_system_metrics", nullptr, nullptr, nullptr);
  G_OBJECT_CLASS(test_messenger_parent_class)->dispose(object);
}

static void test_messenger_class_init(TestMessengerClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = test_messenger_dispose;
}

static void test_messenger_init(TestMessenger* self) {
  self->handler = nullptr;
  self->handler_data = nullptr;
  self->handler_destroy = nullptr;
  self->main_thread = g_thread_self();
  self->responses = 0;
}

FlMethodCodecClass* CodecClass(FlMethodCodec* codec) {
  return FL_METHOD_CODEC_GET_CLASS(codec);
}

TestResponseHandle* Send(TestMessenger* messenger, FlMethodCodec* codec, const char* method) {
  Check(messenger->handler != nullptr, "real method channel registered a messenger handler");
  g_autoptr(GError) error = nullptr;
  g_autoptr(GBytes) message = CodecClass(codec)->encode_method_call(codec, method, nullptr, &error);
  Check(message != nullptr && error == nullptr, "real standard codec encoded method call");
  auto* handle = reinterpret_cast<TestResponseHandle*>(g_object_new(test_response_handle_get_type(), nullptr));
  messenger->handler(FL_BINARY_MESSENGER(messenger), "app_system_metrics", message,
      FL_BINARY_MESSENGER_RESPONSE_HANDLE(handle), messenger->handler_data);
  return handle;
}

FlMethodResponse* Decode(FlMethodCodec* codec, TestResponseHandle* handle) {
  Check(handle->responded && handle->response != nullptr, "method replied through real channel codec");
  g_autoptr(GError) error = nullptr;
  auto* response = CodecClass(codec)->decode_response(codec, handle->response, &error);
  Check(response != nullptr && error == nullptr, "real standard codec decoded response envelope");
  return response;
}

FlValue* Success(FlMethodResponse* response) {
  Check(FL_IS_METHOD_SUCCESS_RESPONSE(response), "method response is successful");
  return fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
}

FlValue* Field(FlValue* map, const char* name, FlValueType type) {
  Check(map != nullptr && fl_value_get_type(map) == FL_VALUE_TYPE_MAP, "expected map envelope");
  auto* value = fl_value_lookup_string(map, name);
  Check(value != nullptr && fl_value_get_type(value) == type, name);
  return value;
}

void CheckOptionalCounter(FlValue* map, const char* name) {
  auto* value = fl_value_lookup_string(map, name);
  Check(value != nullptr && (fl_value_get_type(value) == FL_VALUE_TYPE_NULL ||
      (fl_value_get_type(value) == FL_VALUE_TYPE_INT && fl_value_get_int(value) >= 0)), name);
}

void ValidateActivity(FlValue* value) {
  Check(std::string(fl_value_get_string(Field(value, "platform", FL_VALUE_TYPE_STRING))) == "linux",
      "platform preserved through codec");
  const auto architecture = std::string(fl_value_get_string(Field(value, "architecture", FL_VALUE_TYPE_STRING)));
  Check(architecture == "arm64" || architecture == "x86_64", "architecture normalized through codec");
  Check(fl_value_get_int(Field(value, "timestamp_ms", FL_VALUE_TYPE_INT)) > 0, "valid timestamp");
  Check(fl_value_get_int(Field(value, "monotonic_ms", FL_VALUE_TYPE_INT)) > 0, "valid monotonic counter");
  auto* cores = Field(value, "cores", FL_VALUE_TYPE_LIST);
  Check(fl_value_get_length(cores) > 0, "live CPU cores returned");
  for (std::size_t index = 0; index < fl_value_get_length(cores); ++index) {
    auto* core = fl_value_get_list_value(cores, index);
    Check(fl_value_get_int(Field(core, "id", FL_VALUE_TYPE_INT)) > 0, "positive logical CPU id");
    Field(core, "type", FL_VALUE_TYPE_NULL);
    for (const auto* key : {"user", "system", "nice", "idle"}) {
      Check(fl_value_get_int(Field(core, key, FL_VALUE_TYPE_INT)) >= 0, "unsigned CPU tick through signed int64 codec");
    }
  }
  auto* memory = Field(value, "memory", FL_VALUE_TYPE_MAP);
  Check(fl_value_get_int(Field(memory, "physical", FL_VALUE_TYPE_INT)) > 0, "physical memory returned as int64");
  for (const auto* key : {"available", "free", "active", "inactive", "swap_used", "swap_total"}) {
    CheckOptionalCounter(memory, key);
  }
  Check(fl_value_lookup_string(memory, "wired") == nullptr &&
        fl_value_lookup_string(memory, "compressed") == nullptr &&
        fl_value_lookup_string(memory, "pressure") == nullptr, "no invented macOS memory fields");
  auto* disk = Field(value, "disk", FL_VALUE_TYPE_MAP);
  Field(disk, "devices", FL_VALUE_TYPE_LIST);
  Field(disk, "available", FL_VALUE_TYPE_BOOL);
  for (const auto* key : {"read_bytes", "write_bytes", "read_ops", "write_ops"}) CheckOptionalCounter(disk, key);
  auto* network = Field(value, "network", FL_VALUE_TYPE_MAP);
  Field(network, "available", FL_VALUE_TYPE_BOOL);
  auto* interfaces = Field(network, "interfaces", FL_VALUE_TYPE_LIST);
  for (std::size_t index = 0; index < fl_value_get_length(interfaces); ++index) {
    auto* interface = fl_value_get_list_value(interfaces, index);
    Field(interface, "name", FL_VALUE_TYPE_STRING);
    for (const auto* key : {"rx_bytes", "tx_bytes", "rx_packets", "tx_packets"}) Field(interface, key, FL_VALUE_TYPE_INT);
  }
  CheckOptionalCounter(value, "processes");
  CheckOptionalCounter(value, "threads");
  Field(value, "threads_complete", FL_VALUE_TYPE_BOOL);
  Field(value, "processes_readable", FL_VALUE_TYPE_INT);
  Field(value, "gpu", FL_VALUE_TYPE_LIST);
}

void RoundTripLargeCounters(FlMethodCodec* codec) {
  app_system_metrics::ActivitySnapshot snapshot;
  snapshot.timestamp_ms = 1700000000000;
  snapshot.monotonic_ms = 8589934593LL;
  snapshot.architecture = "arm64";
  snapshot.model = "Codec fixture";
  snapshot.cpu_brand = "Codec CPU";
  snapshot.cores.push_back({1, 8589934593LL, 4294967301LL, 3, 4});
  snapshot.memory = {{"physical", 1099511627776LL}, {"available", std::nullopt}};
  snapshot.disk.available = true;
  snapshot.disk.devices = {"vda"};
  snapshot.disk.read_bytes = 8589934593LL;
  snapshot.network.available = true;
  snapshot.network.interfaces.push_back({"eth0", 8589934593LL, 4294967301LL, 3, 4});
  snapshot.gpu.push_back({"Known GPU", 7.5});
  snapshot.gpu.push_back({"Unreadable GPU", std::nullopt});
  g_autoptr(FlValue) raw = activity_snapshot_value(snapshot);
  g_autoptr(GError) error = nullptr;
  g_autoptr(GBytes) encoded = CodecClass(codec)->encode_success_envelope(codec, raw, &error);
  Check(encoded != nullptr && error == nullptr, "encode production adapter fixture using actual SDK");
  g_autoptr(FlMethodResponse) response = CodecClass(codec)->decode_response(codec, encoded, &error);
  Check(response != nullptr && error == nullptr, "decode production adapter fixture using actual SDK");
  auto* decoded = Success(response);
  auto* core = fl_value_get_list_value(Field(decoded, "cores", FL_VALUE_TYPE_LIST), 0);
  Check(fl_value_get_int(Field(core, "user", FL_VALUE_TYPE_INT)) == 8589934593LL, "CPU >32-bit value preserved");
  Field(core, "type", FL_VALUE_TYPE_NULL);
  auto* memory = Field(decoded, "memory", FL_VALUE_TYPE_MAP);
  Check(fl_value_get_int(Field(memory, "physical", FL_VALUE_TYPE_INT)) == 1099511627776LL,
      "memory >32-bit value preserved");
  Field(memory, "available", FL_VALUE_TYPE_NULL);
  auto* network = Field(decoded, "network", FL_VALUE_TYPE_MAP);
  auto* interface = fl_value_get_list_value(Field(network, "interfaces", FL_VALUE_TYPE_LIST), 0);
  Check(fl_value_get_int(Field(interface, "rx_bytes", FL_VALUE_TYPE_INT)) == 8589934593LL,
      "network >32-bit value preserved");
  auto* disk = Field(decoded, "disk", FL_VALUE_TYPE_MAP);
  Check(fl_value_get_int(Field(disk, "read_bytes", FL_VALUE_TYPE_INT)) == 8589934593LL,
      "disk >32-bit value preserved");
  Field(disk, "write_bytes", FL_VALUE_TYPE_NULL);
  Field(decoded, "processes", FL_VALUE_TYPE_NULL);
  Field(decoded, "threads", FL_VALUE_TYPE_NULL);
  auto* gpu = Field(decoded, "gpu", FL_VALUE_TYPE_LIST);
  auto* known = fl_value_get_list_value(gpu, 0);
  Check(fl_value_get_float(Field(known, "utilization", FL_VALUE_TYPE_FLOAT)) == 7.5, "GPU float preserved");
  Field(fl_value_get_list_value(gpu, 1), "utilization", FL_VALUE_TYPE_NULL);
}

template <typename Predicate>
void Wait(Predicate predicate, const char* message) {
  const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(15);
  while (!predicate() && std::chrono::steady_clock::now() < deadline) {
    while (g_main_context_iteration(nullptr, FALSE)) {}
    g_usleep(1000);
  }
  Check(predicate(), message);
}

void WeakFinalized(gpointer user_data, GObject*) {
  static_cast<std::atomic<bool>*>(user_data)->store(true);
}

void ChannelTests() {
  g_autoptr(TestMessenger) messenger = reinterpret_cast<TestMessenger*>(g_object_new(test_messenger_get_type(), nullptr));
  g_autoptr(FlStandardMethodCodec) standard_codec = fl_standard_method_codec_new();
  FlMethodCodec* codec = FL_METHOD_CODEC(standard_codec);
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      FL_BINARY_MESSENGER(messenger), "app_system_metrics", codec);
  auto* plugin = SYSTEM_METRICS_PLUGIN(g_object_new(system_metrics_plugin_get_type(), nullptr));
  std::atomic<bool> plugin_finalized{false};
  g_object_weak_ref(G_OBJECT(plugin), WeakFinalized, &plugin_finalized);
  fl_method_channel_set_method_call_handler(channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  RoundTripLargeCounters(codec);

  g_autoptr(TestResponseHandle) first_legacy = Send(messenger, codec, "getData");
  g_autoptr(FlMethodResponse) first_response = Decode(codec, first_legacy);
  auto* first_data = Success(first_response);
  Check(std::string(fl_value_get_string(Field(first_data, "platform", FL_VALUE_TYPE_STRING))) == "linux",
      "legacy getData still returns Linux data");
  Field(first_data, "additionalData", FL_VALUE_TYPE_MAP);
  Check(plugin->cached_data != nullptr, "legacy getData retains cache");
  g_autoptr(TestResponseHandle) second_legacy = Send(messenger, codec, "getData");
  g_autoptr(FlMethodResponse) second_response = Decode(codec, second_legacy);
  Check(fl_value_equal(first_data, Success(second_response)), "legacy getData returns cached data");
  g_autoptr(TestResponseHandle) refresh = Send(messenger, codec, "refresh");
  g_autoptr(FlMethodResponse) refresh_response = Decode(codec, refresh);
  auto* refreshed = Success(refresh_response);
  Check((refreshed == nullptr || fl_value_get_type(refreshed) == FL_VALUE_TYPE_NULL) && plugin->cached_data == nullptr,
      "legacy refresh clears cache and returns null");
  g_autoptr(TestResponseHandle) unknown = Send(messenger, codec, "unknownActivityMethod");
  // StandardMethodCodec represents not-implemented as an empty transport reply.
  // Its success/error decode vfunc rejects empty input; assert the wire contract.
  Check(unknown->responded && unknown->response != nullptr && g_bytes_get_size(unknown->response) == 0,
      "unknown methods retain the standard empty not-implemented reply");

  const auto responses_before = messenger->responses;
  g_autoptr(TestResponseHandle) first = Send(messenger, codec, "getActivityData");
  g_autoptr(TestResponseHandle) second = Send(messenger, codec, "getActivityData");
  Check(!first->responded && !second->responded && messenger->responses == responses_before,
      "activity requests do not respond synchronously on GTK thread");
  Wait([&] { return first->responded && second->responded; }, "both concurrent activity requests replied");
  g_autoptr(FlMethodResponse) first_activity = Decode(codec, first);
  g_autoptr(FlMethodResponse) second_activity = Decode(codec, second);
  ValidateActivity(Success(first_activity));
  ValidateActivity(Success(second_activity));
  Check(messenger->responses == responses_before + 2, "each concurrent request responds exactly once");

  g_autoptr(TestResponseHandle) pending = Send(messenger, codec, "getActivityData");
  Check(!pending->responded, "teardown test starts with pending request");
  // Drop the registration and our initial plugin reference while the task owns
  // the only remaining plugin reference. Also remove the transport handler.
  fl_method_channel_set_method_call_handler(channel, nullptr, nullptr, nullptr);
  g_object_unref(plugin);
  plugin = nullptr;
  g_clear_object(&channel);
  fl_binary_messenger_set_message_handler_on_channel(
      FL_BINARY_MESSENGER(messenger), "app_system_metrics", nullptr, nullptr, nullptr);
  Check(!plugin_finalized.load(), "pending GTask retains plugin after handler teardown");
  Wait([&] { return pending->responded && plugin_finalized.load(); },
      "pending request safely replied and plugin was finally released");
  g_autoptr(FlMethodResponse) pending_response = Decode(codec, pending);
  ValidateActivity(Success(pending_response));
}
}  // namespace

int main() {
  try {
    ChannelTests();
    std::cout << checks << " real Flutter Linux codec/channel/task checks passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "Flutter Linux activity channel test failed: " << error.what() << '\n';
    return 1;
  }
}
