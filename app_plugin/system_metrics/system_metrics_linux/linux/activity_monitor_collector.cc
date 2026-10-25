#include "activity_monitor_collector.h"

#include <sys/utsname.h>

#include <algorithm>
#include <charconv>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <limits>
#include <set>
#include <sstream>
#include <stdexcept>
#include <utility>

namespace app_system_metrics {
namespace {
namespace fs = std::filesystem;

std::string Trim(std::string value) {
  const auto begin = value.find_first_not_of(" \t\r\n\0", 0, 5);
  if (begin == std::string::npos) return "";
  const auto end = value.find_last_not_of(" \t\r\n\0", std::string::npos, 5);
  return value.substr(begin, end - begin + 1);
}

std::optional<std::string> ReadFile(const fs::path& path) {
  std::ifstream input(path, std::ios::binary);
  if (!input) return std::nullopt;
  std::ostringstream result;
  result << input.rdbuf();
  if (input.bad()) return std::nullopt;
  return result.str();
}

Counter Number(const std::string& value) {
  if (value.empty()) return std::nullopt;
  std::int64_t result = 0;
  const auto parsed = std::from_chars(value.data(), value.data() + value.size(), result);
  if (parsed.ec != std::errc() || parsed.ptr != value.data() + value.size() || result < 0) {
    return std::nullopt;
  }
  return result;
}

Counter Add(Counter left, Counter right) {
  if (!left || !right || *left > std::numeric_limits<std::int64_t>::max() - *right) {
    return std::nullopt;
  }
  return *left + *right;
}

Counter Scale(Counter value, std::int64_t scale) {
  if (!value || *value > std::numeric_limits<std::int64_t>::max() / scale) {
    return std::nullopt;
  }
  return *value * scale;
}

bool Digits(const std::string& value) {
  return !value.empty() && std::all_of(value.begin(), value.end(), [](char character) {
    return character >= '0' && character <= '9';
  });
}

std::vector<std::string> Fields(const std::string& value) {
  std::istringstream input(value);
  std::vector<std::string> result;
  for (std::string field; input >> field;) result.push_back(field);
  return result;
}

std::map<std::string, std::string> KeyValues(const std::string& text) {
  std::map<std::string, std::string> result;
  std::istringstream input(text);
  for (std::string line; std::getline(input, line);) {
    const auto delimiter = line.find(':');
    if (delimiter != std::string::npos) {
      result[Trim(line.substr(0, delimiter))] = Trim(line.substr(delimiter + 1));
    }
  }
  return result;
}

bool UnrestrictedProcMount(const fs::path& proc) {
  const auto mounts = ReadFile(proc / "mounts");
  if (!mounts) return false;
  std::istringstream input(*mounts);
  for (std::string line; std::getline(input, line);) {
    const auto fields = Fields(line);
    if (fields.size() < 4 || fields[1] != "/proc" || fields[2] != "proc") continue;
    std::istringstream options(fields[3]);
    for (std::string option; std::getline(options, option, ',');) {
      if (option.rfind("hidepid=", 0) == 0 && option != "hidepid=0" && option != "hidepid=off") {
        return false;
      }
    }
    return true;
  }
  return false;
}

void ReadProcesses(const fs::path& proc, ActivitySnapshot* snapshot) {
  std::error_code error;
  fs::directory_iterator iterator(proc, error);
  if (error) return;
  std::int64_t processes = 0;
  Counter threads = 0;
  const bool unrestricted = UnrestrictedProcMount(proc);
  bool complete = unrestricted;
  bool processes_complete = unrestricted;
  bool enumerated = true;
  for (const fs::directory_iterator end; iterator != end; iterator.increment(error)) {
    if (error) { enumerated = false; break; }
    const auto path = iterator->path();
    const auto name = path.filename().string();
    if (!Digits(name) || name == "0") continue;
    std::error_code status_error;
    if (!fs::is_directory(path, status_error)) {
      if (status_error) {
        complete = false;
        processes_complete = false;
      }
      continue;
    }
    const auto status = ReadFile(path / "status");
    if (!status) {
      complete = false;
      // A process can disappear after readdir. Do not retain its stale PID.
      if (!fs::exists(path, status_error) && !status_error) continue;
      ++processes;
      continue;
    }
    ++processes;
    const auto values = KeyValues(*status);
    const auto found = values.find("Threads");
    const auto count = found == values.end() ? std::nullopt : Number(found->second);
    if (!count || *count == 0) { complete = false; continue; }
    ++snapshot->processes_readable;
    threads = Add(threads, count);
    if (!threads) complete = false;
  }
  if (error) enumerated = false;
  // With hidepid, even the visible PID count may omit inaccessible processes.
  if (enumerated && processes_complete) snapshot->processes = processes;
  if (snapshot->processes_readable > 0) snapshot->threads = threads;
  snapshot->threads_complete = enumerated && complete && snapshot->threads.has_value();
}

bool ExcludedDisk(const std::string& name) {
  for (const auto* prefix : {"loop", "ram", "zram", "dm-", "md"}) {
    if (name.rfind(prefix, 0) == 0) return true;
  }
  return false;
}

ActivityDisk ReadDisks(const fs::path& proc, const fs::path& sys) {
  ActivityDisk result;
  std::error_code error;
  fs::directory_iterator iterator(sys / "block", error);
  if (error) return result;
  bool complete = true;
  for (const fs::directory_iterator end; iterator != end; iterator.increment(error)) {
    if (error) { complete = false; break; }
    const auto path = iterator->path();
    const auto name = path.filename().string();
    if (ExcludedDisk(name)) continue;
    std::error_code status_error;
    const bool partition = fs::exists(path / "partition", status_error);
    if (status_error) { complete = false; continue; }
    if (partition) continue;
    const bool device = fs::exists(path / "device", status_error);
    if (status_error) { complete = false; continue; }
    if (!device) continue;  // Other virtual devices (nbd, rbd, etc.).
    fs::directory_iterator slaves(path / "slaves", status_error);
    if (status_error) { complete = false; continue; }
    if (slaves != fs::directory_iterator()) continue;  // Stacked block device.
    result.devices.push_back(name);
  }
  if (error) complete = false;
  std::sort(result.devices.begin(), result.devices.end());
  const auto text = ReadFile(proc / "diskstats");
  if (!text || result.devices.empty() || !complete) return result;
  const auto counters = ParseDiskStats(*text);
  result.read_bytes = 0;
  result.write_bytes = 0;
  result.read_ops = 0;
  result.write_ops = 0;
  for (const auto& name : result.devices) {
    const auto found = counters.find(name);
    const ActivityDiskCounters missing;
    const auto& values = found == counters.end() ? missing : found->second;
    result.read_bytes = Add(result.read_bytes, values.read_bytes);
    result.write_bytes = Add(result.write_bytes, values.write_bytes);
    result.read_ops = Add(result.read_ops, values.read_ops);
    result.write_ops = Add(result.write_ops, values.write_ops);
  }
  result.available = result.read_bytes && result.write_bytes && result.read_ops && result.write_ops;
  return result;
}

std::vector<ActivityGpu> ReadGpus(const fs::path& sys) {
  std::vector<ActivityGpu> result;
  std::error_code error;
  fs::directory_iterator iterator(sys / "class/drm", error);
  if (error) return result;
  for (const fs::directory_iterator end; iterator != end; iterator.increment(error)) {
    if (error) break;
    const auto card = iterator->path().filename().string();
    if (card.rfind("card", 0) != 0 || !Digits(card.substr(4))) continue;
    const auto device = iterator->path() / "device";
    // DRM also exposes display-only and NPU cards. Only an explicit GPU busy
    // interface establishes that this is a GPU we can monitor.
    std::error_code busy_error;
    if (!fs::exists(device / "gpu_busy_percent", busy_error) || busy_error) continue;
    ActivityGpu gpu;
    const auto product = ReadFile(device / "product_name");
    gpu.name = product ? Trim(*product) : card;
    if (!product) {
      const auto uevent = ReadFile(device / "uevent");
      if (uevent) {
        std::istringstream lines(*uevent);
        for (std::string line; std::getline(lines, line);) {
          if (line.rfind("DRIVER=", 0) == 0) gpu.name += " (" + Trim(line.substr(7)) + ")";
        }
      }
    }
    // Explicit driver-exported utilization only. Frequency is not utilization.
    const auto busy = ReadFile(device / "gpu_busy_percent");
    const auto usage = busy ? Number(Trim(*busy)) : std::nullopt;
    if (usage && *usage <= 100) gpu.utilization = static_cast<double>(*usage);
    result.push_back(std::move(gpu));
  }
  std::sort(result.begin(), result.end(), [](const auto& left, const auto& right) {
    return left.name < right.name;
  });
  return result;
}

std::string CpuBrand(const fs::path& proc, const std::string& fallback) {
  const auto info = ReadFile(proc / "cpuinfo");
  if (!info) return fallback;
  const auto values = KeyValues(*info);
  for (const auto* key : {"model name", "Hardware", "Processor"}) {
    const auto found = values.find(key);
    if (found != values.end() && !found->second.empty() && !Digits(found->second)) return found->second;
  }
  return fallback;
}

std::string Model(const fs::path& sys, const std::string& fallback) {
  for (const auto* name : {"devices/virtual/dmi/id/product_name", "firmware/devicetree/base/model"}) {
    const auto value = ReadFile(sys / name);
    if (value && !Trim(*value).empty()) return Trim(*value);
  }
  return fallback;
}
}  // namespace

std::vector<ActivityCpuCore> ParseCpuStat(const std::string& text) {
  std::vector<ActivityCpuCore> result;
  std::set<std::int64_t> ids;
  std::istringstream input(text);
  for (std::string line; std::getline(input, line);) {
    const auto fields = Fields(line);
    if (fields.empty() || fields[0].rfind("cpu", 0) != 0 || !Digits(fields[0].substr(3))) continue;
    const auto index = Number(fields[0].substr(3));
    if (!index || *index == std::numeric_limits<std::int64_t>::max() || fields.size() < 5) {
      throw std::runtime_error("Invalid per-core CPU counters in /proc/stat");
    }
    Counter values[8] = {0, 0, 0, 0, 0, 0, 0, 0};
    for (std::size_t i = 0; i < 8 && i + 1 < fields.size(); ++i) values[i] = Number(fields[i + 1]);
    const auto system = Add(Add(Add(values[2], values[5]), values[6]), values[7]);
    const auto idle = Add(values[3], values[4]);
    if (!values[0] || !values[1] || !system || !idle || !ids.insert(*index + 1).second) {
      throw std::runtime_error("Invalid or overflowing CPU counters in /proc/stat");
    }
    // Linux user/nice already include guest/guest_nice. Do not add them twice.
    result.push_back({*index + 1, *values[0], *system, *values[1], *idle});
  }
  if (result.empty()) throw std::runtime_error("No per-core CPU counters in /proc/stat");
  std::sort(result.begin(), result.end(), [](const auto& left, const auto& right) {
    return left.id < right.id;
  });
  return result;
}

std::map<std::string, Counter> ParseMemInfo(const std::string& text) {
  const auto fields = KeyValues(text);
  const auto bytes = [&fields](const char* key) -> Counter {
    const auto found = fields.find(key);
    if (found == fields.end()) return std::nullopt;
    const auto parts = Fields(found->second);
    if (parts.size() != 2 || parts[1] != "kB") return std::nullopt;
    return Scale(Number(parts[0]), 1024);
  };
  const auto physical = bytes("MemTotal");
  if (!physical || *physical == 0) throw std::runtime_error("Invalid MemTotal in /proc/meminfo");
  auto available = bytes("MemAvailable");
  if (available && *available > *physical) available = std::nullopt;
  const auto swap_total = bytes("SwapTotal");
  const auto swap_free = bytes("SwapFree");
  const Counter swap_used = swap_total && swap_free && *swap_total >= *swap_free
      ? Counter(*swap_total - *swap_free) : std::nullopt;
  return {{"physical", physical}, {"available", available}, {"free", bytes("MemFree")},
          {"active", bytes("Active")}, {"inactive", bytes("Inactive")},
          {"swap_used", swap_used}, {"swap_total", swap_total}};
}

std::map<std::string, ActivityDiskCounters> ParseDiskStats(const std::string& text) {
  std::map<std::string, ActivityDiskCounters> result;
  std::istringstream input(text);
  for (std::string line; std::getline(input, line);) {
    const auto fields = Fields(line);
    if (fields.size() < 3) continue;
    ActivityDiskCounters values;
    if (fields.size() >= 10) {
      values.read_ops = Number(fields[3]);
      values.read_bytes = Scale(Number(fields[5]), 512);
      values.write_ops = Number(fields[7]);
      values.write_bytes = Scale(Number(fields[9]), 512);
    }
    const auto inserted = result.emplace(fields[2], values);
    if (!inserted.second) inserted.first->second = ActivityDiskCounters();
  }
  return result;
}

ActivityNetwork ParseNetworkDev(const std::string& text) {
  ActivityNetwork result;
  std::istringstream input(text);
  std::string header;
  if (!std::getline(input, header) || header.find("Receive") == std::string::npos ||
      header.find("Transmit") == std::string::npos || !std::getline(input, header) ||
      header.find("bytes") == std::string::npos) return result;
  result.available = true;
  std::set<std::string> names;
  for (std::string line; std::getline(input, line);) {
    if (Trim(line).empty()) continue;
    const auto delimiter = line.rfind(':');
    if (delimiter == std::string::npos) { result.available = false; continue; }
    const auto name = Trim(line.substr(0, delimiter));
    if (name == "lo") continue;
    const auto fields = Fields(line.substr(delimiter + 1));
    if (name.empty() || fields.size() < 16 || !names.insert(name).second) {
      result.available = false;
      continue;
    }
    const auto rx_bytes = Number(fields[0]);
    const auto rx_packets = Number(fields[1]);
    const auto tx_bytes = Number(fields[8]);
    const auto tx_packets = Number(fields[9]);
    if (!rx_bytes || !rx_packets || !tx_bytes || !tx_packets) {
      result.available = false;
      continue;
    }
    result.interfaces.push_back({name, *rx_bytes, *tx_bytes, *rx_packets, *tx_packets});
  }
  std::sort(result.interfaces.begin(), result.interfaces.end(), [](const auto& left, const auto& right) {
    return left.name < right.name;
  });
  return result;
}

std::string NormalizeArchitecture(const std::string& machine) {
  if (machine == "aarch64" || machine == "arm64") return "arm64";
  if (machine == "amd64" || machine == "x86_64") return "x86_64";
  return machine;
}

ActivityMonitorCollector::ActivityMonitorCollector(std::string proc_root, std::string sys_root)
    : proc_root_(std::move(proc_root)), sys_root_(std::move(sys_root)) {}

ActivitySnapshot ActivityMonitorCollector::Snapshot() const {
  struct utsname system {};
  if (uname(&system) != 0) throw std::runtime_error("Unable to read Linux system identity");
  const fs::path proc(proc_root_);
  const fs::path sys(sys_root_);
  const auto cpu = ReadFile(proc / "stat");
  if (!cpu) throw std::runtime_error("Unable to read /proc/stat");
  const auto memory = ReadFile(proc / "meminfo");
  if (!memory) throw std::runtime_error("Unable to read /proc/meminfo");
  ActivitySnapshot result;
  result.timestamp_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
      std::chrono::system_clock::now().time_since_epoch()).count();
  result.monotonic_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
      std::chrono::steady_clock::now().time_since_epoch()).count();
  result.architecture = NormalizeArchitecture(system.machine);
  result.model = Model(sys, std::string(system.sysname) + " " + result.architecture);
  result.cpu_brand = CpuBrand(proc, result.architecture);
  result.cores = ParseCpuStat(*cpu);
  result.memory = ParseMemInfo(*memory);
  result.disk = ReadDisks(proc, sys);
  const auto network = ReadFile(proc / "net/dev");
  if (network) result.network = ParseNetworkDev(*network);
  result.gpu = ReadGpus(sys);
  ReadProcesses(proc, &result);
  return result;
}

}  // namespace app_system_metrics
