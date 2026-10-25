#include "include/app_system_metrics_linux/system_metrics_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <gio/gio.h>
#include <sys/utsname.h>
#include <cstring>
#include <exception>
#include <memory>
#include <mutex>

#include "activity_monitor_collector.h"

#define SYSTEM_METRICS_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), system_metrics_plugin_get_type(), \
                               SystemMetricsPlugin))

struct _SystemMetricsPlugin {
  GObject parent_instance;
  FlValue* cached_data;
};

G_DEFINE_TYPE(SystemMetricsPlugin, system_metrics_plugin, g_object_get_type())

// Get system information
static FlValue* get_data(SystemMetricsPlugin* self) {
  if (self->cached_data != nullptr) {
    return fl_value_ref(self->cached_data);
  }

  struct utsname buffer;
  if (uname(&buffer) != 0) {
    return nullptr;
  }

  g_autoptr(FlValue) additional_data = fl_value_new_map();
  fl_value_set_string_take(additional_data, "sysname",
                           fl_value_new_string(buffer.sysname));
  fl_value_set_string_take(additional_data, "nodename",
                           fl_value_new_string(buffer.nodename));
  fl_value_set_string_take(additional_data, "release",
                           fl_value_new_string(buffer.release));
  fl_value_set_string_take(additional_data, "version",
                           fl_value_new_string(buffer.version));
  fl_value_set_string_take(additional_data, "machine",
                           fl_value_new_string(buffer.machine));

  g_autoptr(FlValue) result = fl_value_new_map();
  fl_value_set_string_take(result, "platform", fl_value_new_string("linux"));

  // Get current timestamp
  g_autoptr(GDateTime) now = g_date_time_new_now_utc();
  g_autofree gchar* timestamp = g_date_time_format_iso8601(now);
  fl_value_set_string_take(result, "timestamp", fl_value_new_string(timestamp));

  fl_value_set_string_take(result, "additionalData", fl_value_ref(additional_data));

  self->cached_data = fl_value_ref(result);
  return fl_value_ref(result);
}

// Convert the independently tested collector model at the Flutter boundary.
static FlValue* activity_counter(app_system_metrics::Counter value) {
  return value ? fl_value_new_int(*value) : fl_value_new_null();
}

static FlValue* activity_snapshot_value(const app_system_metrics::ActivitySnapshot& data) {
  FlValue* result = fl_value_new_map();
  fl_value_set_string_take(result, "platform", fl_value_new_string("linux"));
  fl_value_set_string_take(result, "timestamp_ms", fl_value_new_int(data.timestamp_ms));
  fl_value_set_string_take(result, "monotonic_ms", fl_value_new_int(data.monotonic_ms));
  fl_value_set_string_take(result, "architecture", fl_value_new_string(data.architecture.c_str()));
  fl_value_set_string_take(result, "model", fl_value_new_string(data.model.c_str()));
  fl_value_set_string_take(result, "cpu_brand", fl_value_new_string(data.cpu_brand.c_str()));
  FlValue* cores = fl_value_new_list();
  for (const auto& core : data.cores) {
    FlValue* value = fl_value_new_map();
    fl_value_set_string_take(value, "id", fl_value_new_int(core.id));
    fl_value_set_string_take(value, "type", fl_value_new_null());
    fl_value_set_string_take(value, "user", fl_value_new_int(core.user));
    fl_value_set_string_take(value, "system", fl_value_new_int(core.system));
    fl_value_set_string_take(value, "nice", fl_value_new_int(core.nice));
    fl_value_set_string_take(value, "idle", fl_value_new_int(core.idle));
    fl_value_append_take(cores, value);
  }
  fl_value_set_string_take(result, "cores", cores);
  fl_value_set_string_take(result, "processes", activity_counter(data.processes));
  fl_value_set_string_take(result, "threads", activity_counter(data.threads));
  fl_value_set_string_take(result, "threads_complete", fl_value_new_bool(data.threads_complete));
  fl_value_set_string_take(result, "processes_readable", fl_value_new_int(data.processes_readable));
  FlValue* memory = fl_value_new_map();
  for (const auto& field : data.memory) {
    fl_value_set_string_take(memory, field.first.c_str(), activity_counter(field.second));
  }
  fl_value_set_string_take(result, "memory", memory);
  FlValue* disk = fl_value_new_map();
  FlValue* devices = fl_value_new_list();
  for (const auto& name : data.disk.devices) fl_value_append_take(devices, fl_value_new_string(name.c_str()));
  fl_value_set_string_take(disk, "devices", devices);
  fl_value_set_string_take(disk, "available", fl_value_new_bool(data.disk.available));
  fl_value_set_string_take(disk, "read_bytes", activity_counter(data.disk.read_bytes));
  fl_value_set_string_take(disk, "write_bytes", activity_counter(data.disk.write_bytes));
  fl_value_set_string_take(disk, "read_ops", activity_counter(data.disk.read_ops));
  fl_value_set_string_take(disk, "write_ops", activity_counter(data.disk.write_ops));
  fl_value_set_string_take(result, "disk", disk);
  FlValue* network = fl_value_new_map();
  FlValue* interfaces = fl_value_new_list();
  for (const auto& interface : data.network.interfaces) {
    FlValue* value = fl_value_new_map();
    fl_value_set_string_take(value, "name", fl_value_new_string(interface.name.c_str()));
    fl_value_set_string_take(value, "rx_bytes", fl_value_new_int(interface.rx_bytes));
    fl_value_set_string_take(value, "tx_bytes", fl_value_new_int(interface.tx_bytes));
    fl_value_set_string_take(value, "rx_packets", fl_value_new_int(interface.rx_packets));
    fl_value_set_string_take(value, "tx_packets", fl_value_new_int(interface.tx_packets));
    fl_value_append_take(interfaces, value);
  }
  fl_value_set_string_take(network, "interfaces", interfaces);
  fl_value_set_string_take(network, "available", fl_value_new_bool(data.network.available));
  fl_value_set_string_take(result, "network", network);
  FlValue* gpus = fl_value_new_list();
  for (const auto& gpu : data.gpu) {
    FlValue* value = fl_value_new_map();
    fl_value_set_string_take(value, "name", fl_value_new_string(gpu.name.c_str()));
    fl_value_set_string_take(value, "utilization", gpu.utilization
        ? fl_value_new_float(*gpu.utilization) : fl_value_new_null());
    fl_value_append_take(gpus, value);
  }
  fl_value_set_string_take(result, "gpu", gpus);
  return result;
}

static void collect_activity_thread(GTask* task, gpointer, gpointer, GCancellable*) {
  // Independent callers share a serial native sampler, without blocking GTK.
  static std::mutex sampling_mutex;
  try {
    std::lock_guard<std::mutex> lock(sampling_mutex);
    auto snapshot = std::make_unique<app_system_metrics::ActivitySnapshot>(
        app_system_metrics::ActivityMonitorCollector().Snapshot());
    g_task_return_pointer(task, snapshot.release(), [](gpointer value) {
      delete static_cast<app_system_metrics::ActivitySnapshot*>(value);
    });
  } catch (const std::exception& error) {
    g_task_return_new_error(task, g_quark_from_static_string("app-system-metrics-activity"),
                            1, "%s", error.what());
  }
}

static void activity_ready(GObject*, GAsyncResult* result, gpointer) {
  // GTask invokes this on the originating GTK main context. It owns both the
  // plugin and the method call until this reply has finished, including teardown.
  GTask* task = G_TASK(result);
  FlMethodCall* method_call = FL_METHOD_CALL(g_task_get_task_data(task));
  g_autoptr(GError) error = nullptr;
  std::unique_ptr<app_system_metrics::ActivitySnapshot> snapshot(
      static_cast<app_system_metrics::ActivitySnapshot*>(g_task_propagate_pointer(task, &error)));
  g_autoptr(FlMethodResponse) response = nullptr;
  if (error != nullptr) {
    response = FL_METHOD_RESPONSE(fl_method_error_response_new(
        "ACTIVITY_UNAVAILABLE", error->message, nullptr));
  } else {
    g_autoptr(FlValue) value = activity_snapshot_value(*snapshot);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  }
  fl_method_call_respond(method_call, response, nullptr);
}

// Called when a method call is received from Flutter
static void system_metrics_plugin_handle_method_call(
    SystemMetricsPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getActivityData") == 0) {
    GTask* task = g_task_new(self, nullptr, activity_ready, nullptr);
    g_task_set_task_data(task, g_object_ref(method_call), g_object_unref);
    g_task_run_in_thread(task, collect_activity_thread);
    g_object_unref(task);
    return;
  }

  if (strcmp(method, "getData") == 0) {
    g_autoptr(FlValue) result = get_data(self);
    if (result != nullptr) {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "ERROR", "Failed to get data", nullptr));
    }
  } else if (strcmp(method, "refresh") == 0) {
    if (self->cached_data != nullptr) {
      fl_value_unref(self->cached_data);
      self->cached_data = nullptr;
    }
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void system_metrics_plugin_dispose(GObject* object) {
  SystemMetricsPlugin* self = SYSTEM_METRICS_PLUGIN(object);
  if (self->cached_data != nullptr) {
    fl_value_unref(self->cached_data);
    self->cached_data = nullptr;
  }
  G_OBJECT_CLASS(system_metrics_plugin_parent_class)->dispose(object);
}

static void system_metrics_plugin_class_init(SystemMetricsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = system_metrics_plugin_dispose;
}

static void system_metrics_plugin_init(SystemMetricsPlugin* self) {
  self->cached_data = nullptr;
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                          gpointer user_data) {
  SystemMetricsPlugin* plugin = SYSTEM_METRICS_PLUGIN(user_data);
  system_metrics_plugin_handle_method_call(plugin, method_call);
}

void system_metrics_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  SystemMetricsPlugin* plugin = SYSTEM_METRICS_PLUGIN(
      g_object_new(system_metrics_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                           "app_system_metrics",
                           FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                           g_object_ref(plugin),
                                           g_object_unref);

  g_object_unref(plugin);
}
