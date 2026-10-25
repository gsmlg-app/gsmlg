#include "../linux/activity_monitor_collector.h"

#include <chrono>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iostream>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>

namespace {
namespace fs = std::filesystem;
namespace metrics = app_system_metrics;
int checks = 0;

void Check(bool condition, const std::string& message) {
  ++checks;
  if (!condition) throw std::runtime_error(message);
}

void Throws(const std::function<void()>& action, const std::string& message) {
  bool threw = false;
  try { action(); } catch (const std::runtime_error&) { threw = true; }
  Check(threw, message);
}

const char* kNetwork =
    "Inter-|   Receive                                                |  Transmit\n"
    " face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed\n"
    "    lo: 999 9 0 0 0 0 0 0 999 9 0 0 0 0 0 0\n"
    "  eth0: 8589934593 123 0 0 0 0 0 0 4294967301 456 0 0 0 0 0 0\n"
    "   wg0: 1000 10 0 0 0 0 0 0 2000 20 0 0 0 0 0 0\n";

struct Fixture {
  fs::path root;
  Fixture() {
    const auto suffix = std::chrono::high_resolution_clock::now().time_since_epoch().count();
    root = fs::temp_directory_path() / ("gsmlg-activity-fixture-" + std::to_string(suffix));
    Check(fs::create_directory(root), "create isolated fixture directory");
    Write("proc/stat", "cpu 1000 200 300 400 50 60 70 80 90 100\n"
        "cpu2 4294967301 3 4 5 6 7 8 9 100 200\ncpu0 100 20 30 40 5 6 7 8 9 10\n");
    Write("proc/meminfo", "MemTotal: 100000 kB\nMemAvailable: 60000 kB\nMemFree: 10000 kB\n"
        "Active: 20000 kB\nInactive: 30000 kB\nSwapTotal: 1000 kB\nSwapFree: 250 kB\n");
    Write("proc/cpuinfo", "processor : 0\nmodel name : Fixture CPU\n");
    Write("proc/mounts", "proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0\n");
    Write("proc/100/status", "Name:\tfixture one\nThreads:\t3\n");
    Write("proc/200/status", "Name:\tfixture two\nThreads:\t5\n");
    Write("proc/net/dev", kNetwork);
    Write("sys/devices/virtual/dmi/id/product_name", "Fixture Workstation\n");
    AddDisk("sda");
    AddDisk("vda");
    AddDisk("nvme0n1");
    AddDisk("sda1");
    Write("sys/block/sda1/partition", "1\n");
    for (const auto* name : {"loop0", "ram0", "zram0", "md0", "dm-0"}) AddDisk(name);
    AddDisk("stacked0");
    Write("sys/block/stacked0/slaves/sda", "");
    fs::create_directories(root / "sys/block/nbd0/slaves");
    Write("proc/diskstats", "8 0 sda 10 0 20 0 30 0 40 0 0 0 0\n"
        "252 0 vda 4294967300 0 8589934593 0 4294967301 0 4294967302 0 0 0 0\n"
        "259 0 nvme0n1 5 0 6 0 7 0 8 0 0 0 0\n"
        "8 1 sda1 999 0 999 0 999 0 999 0 0 0 0\n"
        "7 0 loop0 999 0 999 0 999 0 999 0 0 0 0\n"
        "253 0 dm-0 999 0 999 0 999 0 999 0 0 0 0\n");
    Write("sys/class/drm/card0/device/product_name", "Fixture GPU\n");
    Write("sys/class/drm/card0/device/gpu_busy_percent", "25\n");
    Write("sys/class/drm/card1/device/uevent", "DRIVER=rockchip-drm\n");
    Write("sys/class/drm/card2/device/uevent", "DRIVER=amdgpu\n");
    Write("sys/class/drm/card2/device/gpu_busy_percent", "101\n");
    Write("sys/class/drm/card3/device/uevent", "DRIVER=RKNPU\n");
    Write("sys/class/drm/card0-DP-1/device/gpu_busy_percent", "99\n");
  }
  ~Fixture() {
    std::error_code error;
    fs::remove_all(root, error);
  }
  void Write(const std::string& name, const std::string& contents) const {
    const auto path = root / name;
    fs::create_directories(path.parent_path());
    std::ofstream output(path, std::ios::binary);
    output << contents;
    if (!output) throw std::runtime_error("write fixture " + name);
  }
  void AddDisk(const std::string& name) const {
    fs::create_directories(root / "sys/block" / name / "device");
    fs::create_directories(root / "sys/block" / name / "slaves");
  }
  metrics::ActivitySnapshot Sample() const {
    return metrics::ActivityMonitorCollector((root / "proc").string(), (root / "sys").string()).Snapshot();
  }
};

void ParserTests() {
  const auto cores = metrics::ParseCpuStat("cpu 999 999 999 999\n"
      "cpu0 100 20 30 40 5 6 7 8 9000 8000\ncpu3 4294967301 1 2 3\n");
  Check(cores.size() == 2, "ignore aggregate CPU line");
  Check(cores[0].id == 1 && cores[1].id == 4, "preserve noncontiguous logical CPU IDs");
  Check(cores[0].user == 100 && cores[0].nice == 20, "guest time is already in user/nice");
  Check(cores[0].system == 51, "system includes IRQ, softirq and steal once");
  Check(cores[0].idle == 45, "idle includes iowait");
  Check(cores[1].user == 4294967301, "preserve CPU counters above 32 bits");
  Throws([] { metrics::ParseCpuStat("cpu 1 2 3 4\n"); }, "empty CPU data is a system error");
  Throws([] { metrics::ParseCpuStat("cpu0 -1 2 3 4\n"); }, "reject negative CPU counters");
  Throws([] { metrics::ParseCpuStat("cpu0 1 2 3 4\ncpu0 1 2 3 4\n"); }, "reject duplicate CPU IDs");
  Throws([] { metrics::ParseCpuStat("cpu0 1 2 9223372036854775807 4 0 1\n"); }, "checked CPU arithmetic");
  Throws([] { metrics::ParseMemInfo("MemTotal: 18446744073709551615 kB\n"); }, "reject overflowing physical memory");
  const auto memory = metrics::ParseMemInfo("MemTotal: 100 kB\nMemAvailable: 101 kB\n"
      "SwapTotal: 100 kB\nSwapFree: 101 kB\nActive: 20 B\n");
  Check(memory.at("physical") == 102400, "kernel kB means 1024 bytes");
  Check(!memory.at("available") && !memory.at("swap_used") && !memory.at("active"),
        "invalid optional memory remains unavailable");
  Check(memory.count("wired") == 0 && memory.count("compressed") == 0 && memory.count("pressure") == 0,
        "do not manufacture macOS memory fields");
  const auto network = metrics::ParseNetworkDev(kNetwork);
  Check(network.available && network.interfaces.size() == 2, "exclude loopback, keep separate real/virtual interfaces");
  Check(network.interfaces[0].rx_bytes == 8589934593 && network.interfaces[0].tx_bytes == 4294967301,
        "preserve 64-bit network counters");
  Check(!metrics::ParseNetworkDev("").available, "missing network header is unavailable");
  Check(!metrics::ParseNetworkDev(std::string(kNetwork) + "broken:\n").available,
        "malformed interface cannot produce a complete network sample");
  const auto disk = metrics::ParseDiskStats("8 0 sda 3 0 8589934593 0 4 0 20 0 0 0 0\n"
      "8 1 bad 1 0 9223372036854775807 0 2 0 5 0 0 0 0\n");
  Check(disk.at("sda").read_bytes == 8589934593LL * 512, "diskstats sectors are always 512 bytes");
  Check(!disk.at("bad").read_bytes, "reject sector-to-byte overflow");
  Check(metrics::NormalizeArchitecture("aarch64") == "arm64" &&
        metrics::NormalizeArchitecture("x86_64") == "x86_64", "normalize Linux architecture names");
}

void FixtureTests() {
  Fixture fixture;
  const auto sample = fixture.Sample();
  Check(sample.model == "Fixture Workstation" && sample.cpu_brand == "Fixture CPU", "read device identity");
  Check(sample.cores.size() == 2 && sample.cores[0].id == 1 && sample.cores[1].id == 3, "sort per-core counters");
  Check(sample.memory.at("physical") == 102400000 && sample.memory.at("available") == 61440000,
        "physical/available memory contract");
  Check(sample.memory.at("swap_used") == 768000, "derive swap used without guessing");
  Check(sample.disk.available && sample.disk.devices == std::vector<std::string>({"nvme0n1", "sda", "vda"}),
        "include whole physical/virtio disks; exclude partitions, virtual and stacked disks");
  Check(sample.disk.read_bytes == (20LL + 8589934593LL + 6LL) * 512 &&
        sample.disk.write_bytes == (40LL + 4294967302LL + 8LL) * 512,
        "aggregate each backing disk once with 64-bit counters");
  Check(sample.network.available && sample.network.interfaces.size() == 2, "read network fixture");
  Check(sample.gpu.size() == 2 && sample.gpu[0].name == "Fixture GPU" && sample.gpu[0].utilization == 25 &&
        !sample.gpu[1].utilization, "GPU requires driver utilization interface, never count display/NPU cards");
  Check(sample.processes == 2 && sample.threads == 8 && sample.processes_readable == 2 && sample.threads_complete,
        "complete process/thread snapshot when every PID is readable");
  fs::create_directories(fixture.root / "proc/300");
  auto partial = fixture.Sample();
  Check(partial.processes == 3 && partial.threads == 8 && partial.processes_readable == 2 && !partial.threads_complete,
        "unreadable/racing process must not claim complete threads");
  fixture.Write("proc/300/status", "Threads:\tinvalid\n");
  partial = fixture.Sample();
  Check(partial.processes == 3 && partial.threads == 8 && !partial.threads_complete,
        "invalid process Threads field is partial, not zero");
  fs::remove_all(fixture.root / "proc/300");
  fixture.Write("proc/mounts", "proc /proc proc rw,hidepid=2 0 0\n");
  const auto hidden = fixture.Sample();
  Check(!hidden.threads_complete && !hidden.processes,
        "hidepid process filtering cannot claim complete threads or a total process count");
  fs::remove(fixture.root / "proc/diskstats");
  fs::remove(fixture.root / "proc/net/dev");
  fs::remove_all(fixture.root / "sys/class/drm");
  const auto missing = fixture.Sample();
  Check(!missing.disk.available && !missing.disk.read_bytes && !missing.network.available && missing.gpu.empty(),
        "local subsystem failure preserves unavailable metrics");
  fixture.Write("proc/meminfo", "MemTotal: 100 kB\n");
  Check(!fixture.Sample().memory.at("available"), "missing MemAvailable must not be replaced with MemFree");
  fs::remove(fixture.root / "proc/stat");
  Throws([&fixture] { fixture.Sample(); }, "unreadable system CPU source throws");
}

std::string Quote(const std::string& value) {
  std::ostringstream result;
  result << '"';
  const char* hex = "0123456789abcdef";
  for (unsigned char character : value) {
    if (character == '"' || character == '\\') result << '\\' << character;
    else if (character < 0x20) result << "\\u00" << hex[character >> 4] << hex[character & 15];
    else result << character;
  }
  result << '"';
  return result.str();
}

std::string Counter(metrics::Counter value) { return value ? std::to_string(*value) : "null"; }

std::string Json(const metrics::ActivitySnapshot& data) {
  std::ostringstream out;
  out << "{\"platform\":\"linux\",\"timestamp_ms\":" << data.timestamp_ms
      << ",\"monotonic_ms\":" << data.monotonic_ms << ",\"architecture\":" << Quote(data.architecture)
      << ",\"model\":" << Quote(data.model) << ",\"cpu_brand\":" << Quote(data.cpu_brand) << ",\"cores\":[";
  bool first = true;
  for (const auto& core : data.cores) {
    if (!first) out << ',';
    first = false;
    out << "{\"id\":" << core.id << ",\"type\":null,\"user\":" << core.user << ",\"system\":" << core.system
        << ",\"nice\":" << core.nice << ",\"idle\":" << core.idle << '}';
  }
  out << "],\"processes\":" << Counter(data.processes) << ",\"threads\":" << Counter(data.threads)
      << ",\"threads_complete\":" << (data.threads_complete ? "true" : "false")
      << ",\"processes_readable\":" << data.processes_readable << ",\"memory\":{";
  first = true;
  for (const auto& value : data.memory) {
    if (!first) out << ',';
    first = false;
    out << Quote(value.first) << ':' << Counter(value.second);
  }
  out << "},\"disk\":{\"devices\":[";
  first = true;
  for (const auto& name : data.disk.devices) {
    if (!first) out << ',';
    first = false;
    out << Quote(name);
  }
  out << "],\"available\":" << (data.disk.available ? "true" : "false")
      << ",\"read_bytes\":" << Counter(data.disk.read_bytes) << ",\"write_bytes\":" << Counter(data.disk.write_bytes)
      << ",\"read_ops\":" << Counter(data.disk.read_ops) << ",\"write_ops\":" << Counter(data.disk.write_ops)
      << "},\"network\":{\"available\":" << (data.network.available ? "true" : "false") << ",\"interfaces\":[";
  first = true;
  for (const auto& value : data.network.interfaces) {
    if (!first) out << ',';
    first = false;
    out << "{\"name\":" << Quote(value.name) << ",\"rx_bytes\":" << value.rx_bytes << ",\"tx_bytes\":" << value.tx_bytes
        << ",\"rx_packets\":" << value.rx_packets << ",\"tx_packets\":" << value.tx_packets << '}';
  }
  out << "]},\"gpu\":[";
  first = true;
  for (const auto& value : data.gpu) {
    if (!first) out << ',';
    first = false;
    out << "{\"name\":" << Quote(value.name) << ",\"utilization\":"
        << (value.utilization ? std::to_string(*value.utilization) : "null") << '}';
  }
  out << "]}";
  return out.str();
}

void Live(bool json) {
  metrics::ActivityMonitorCollector collector;
  const auto before = collector.Snapshot();
  if (json) std::cout << Json(before) << '\n';
  std::this_thread::sleep_for(std::chrono::milliseconds(1100));
  const auto after = collector.Snapshot();
  if (json) std::cout << Json(after) << '\n';
  Check(before.timestamp_ms > 0 && after.timestamp_ms > 0 && after.monotonic_ms > before.monotonic_ms,
        "valid realtime timestamp and advancing monotonic clock");
  Check(after.architecture == "x86_64" || after.architecture == "arm64", "supported live architecture");
  Check(!after.cores.empty() && after.memory.at("physical").value_or(0) > 0, "live CPU/memory available");
  if (!json) {
    std::cout << "Linux live snapshot passed: arch=" << after.architecture << " cores=" << after.cores.size()
        << " disks=" << after.disk.devices.size() << " disk_available=" << after.disk.available
        << " network_interfaces=" << after.network.interfaces.size() << " network_available=" << after.network.available
        << " gpus=" << after.gpu.size() << " processes=" << Counter(after.processes)
        << " threads=" << Counter(after.threads) << " threads_complete=" << after.threads_complete << '\n';
  }
}
}  // namespace

int main(int argc, char** argv) {
  try {
    const std::string mode = argc > 1 ? argv[1] : "--fixtures";
    if (mode == "--sample-json") Live(true);
    else if (mode == "--live") Live(false);
    else if (mode == "--fixtures") {
      ParserTests();
      FixtureTests();
      std::cout << checks << " native parser/fixture checks passed\n";
    } else throw std::runtime_error("usage: activity_monitor_collector_test [--fixtures|--live|--sample-json]");
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "Activity monitor test failed: " << error.what() << '\n';
    return 1;
  }
}
