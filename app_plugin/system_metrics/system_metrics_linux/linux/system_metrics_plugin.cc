#include "include/app_system_metrics_linux/system_metrics_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <cstring>

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

// Called when a method call is received from Flutter
static void system_metrics_plugin_handle_method_call(
    SystemMetricsPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

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
