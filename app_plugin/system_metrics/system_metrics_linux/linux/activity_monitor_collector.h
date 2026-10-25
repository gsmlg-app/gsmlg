#ifndef APP_SYSTEM_METRICS_ACTIVITY_MONITOR_COLLECTOR_H_
#define APP_SYSTEM_METRICS_ACTIVITY_MONITOR_COLLECTOR_H_

#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <vector>

namespace app_system_metrics {

// All integers fit FlutterStandardMessageCodec's signed 64-bit representation.
using Counter = std::optional<std::int64_t>;

struct ActivityCpuCore {
  std::int64_t id;
  std::int64_t user;
  std::int64_t system;
  std::int64_t nice;
  std::int64_t idle;
};

struct ActivityDiskCounters {
  Counter read_bytes;
  Counter write_bytes;
  Counter read_ops;
  Counter write_ops;
};

struct ActivityDisk : ActivityDiskCounters {
  bool available = false;
  std::vector<std::string> devices;
};

struct ActivityNetworkInterface {
  std::string name;
  std::int64_t rx_bytes;
  std::int64_t tx_bytes;
  std::int64_t rx_packets;
  std::int64_t tx_packets;
};

struct ActivityNetwork {
  bool available = false;
  std::vector<ActivityNetworkInterface> interfaces;
};

struct ActivityGpu {
  std::string name;
  std::optional<double> utilization;
};

struct ActivitySnapshot {
  std::int64_t timestamp_ms = 0;
  std::int64_t monotonic_ms = 0;
  std::string architecture;
  std::string model;
  std::string cpu_brand;
  std::vector<ActivityCpuCore> cores;
  std::map<std::string, Counter> memory;
  ActivityDisk disk;
  ActivityNetwork network;
  std::vector<ActivityGpu> gpu;
  Counter processes;
  Counter threads;
  std::int64_t processes_readable = 0;
  bool threads_complete = false;
};

// Exposed parsers keep kernel format and overflow cases independently testable.
std::vector<ActivityCpuCore> ParseCpuStat(const std::string& text);
std::map<std::string, Counter> ParseMemInfo(const std::string& text);
std::map<std::string, ActivityDiskCounters> ParseDiskStats(const std::string& text);
ActivityNetwork ParseNetworkDev(const std::string& text);
std::string NormalizeArchitecture(const std::string& machine);

class ActivityMonitorCollector {
 public:
  explicit ActivityMonitorCollector(std::string proc_root = "/proc",
                                    std::string sys_root = "/sys");

  // Required CPU/physical-memory failures throw. Optional subsystems stay null.
  ActivitySnapshot Snapshot() const;

 private:
  std::string proc_root_;
  std::string sys_root_;
};

}  // namespace app_system_metrics

#endif  // APP_SYSTEM_METRICS_ACTIVITY_MONITOR_COLLECTOR_H_
