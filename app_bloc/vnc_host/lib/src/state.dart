part of 'bloc.dart';

@immutable
final class VncHostState extends Equatable {
  const VncHostState({
    this.hosts = const [],
    this.discoveredHosts = const [],
    this.isLoading = false,
    this.isDiscovering = false,
    this.error,
  });

  final List<VncHost> hosts;
  final List<VncDiscoveredHost> discoveredHosts;
  final bool isLoading;
  final bool isDiscovering;
  final Object? error;

  VncHostState copyWith({
    List<VncHost>? hosts,
    List<VncDiscoveredHost>? discoveredHosts,
    bool? isLoading,
    bool? isDiscovering,
    Object? error,
    bool clearError = false,
  }) {
    return VncHostState(
      hosts: hosts ?? this.hosts,
      discoveredHosts: discoveredHosts ?? this.discoveredHosts,
      isLoading: isLoading ?? this.isLoading,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    hosts,
    discoveredHosts,
    isLoading,
    isDiscovering,
    error,
  ];
}
