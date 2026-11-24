import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_vnc/app_vnc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'repository.dart';

part 'event.dart';
part 'state.dart';

/// BLoC managing saved VNC hosts, credentials, and Bonjour/mDNS LAN discovery.
class VncHostBloc extends Bloc<VncHostEvent, VncHostState> {
  VncHostBloc({required this.repository, VncMdnsDiscovery? discovery})
    : _discovery = discovery ?? VncMdnsDiscovery(),
      super(const VncHostState()) {
    on<VncHostLoad>(_onLoad);
    on<VncHostAdd>(_onAdd);
    on<VncHostUpdate>(_onUpdate);
    on<VncHostDelete>(_onDelete);
    on<VncHostMarkConnected>(_onMarkConnected);
    on<VncHostDiscoverLan>(_onDiscoverLan);
    on<_VncLanHostDiscovered>(_onLanHostDiscovered);
    on<_VncLanDiscoveryFailed>(_onLanDiscoveryFailed);
    on<_VncLanDiscoveryCompleted>(_onLanDiscoveryCompleted);
  }

  final VncHostRepository repository;
  final VncMdnsDiscovery _discovery;

  StreamSubscription<VncDiscoveredHost>? _discoverySubscription;
  int _discoveryGeneration = 0;

  Future<void> _onLoad(VncHostLoad event, Emitter<VncHostState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final hosts = await repository.loadHosts();
      emit(state.copyWith(hosts: List.unmodifiable(hosts), isLoading: false));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    }
  }

  Future<void> _onAdd(VncHostAdd event, Emitter<VncHostState> emit) async {
    emit(state.copyWith(clearError: true));
    try {
      await repository.addHost(
        name: event.name,
        host: event.host,
        port: event.port,
        authType: event.authType,
        username: event.username,
        password: event.password,
        sshHostId: event.sshHostId,
        viewOnly: event.viewOnly,
      );
      final hosts = await repository.loadHosts();
      emit(state.copyWith(hosts: List.unmodifiable(hosts)));
    } catch (error) {
      emit(state.copyWith(error: error));
    }
  }

  Future<void> _onUpdate(
    VncHostUpdate event,
    Emitter<VncHostState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
    try {
      await repository.updateHost(
        event.id,
        name: event.name,
        host: event.host,
        port: event.port,
        authType: event.authType,
        username: event.username,
        password: event.password,
        clearPassword: event.clearPassword,
        sshHostId: event.sshHostId,
        viewOnly: event.viewOnly,
      );
      final hosts = await repository.loadHosts();
      emit(state.copyWith(hosts: List.unmodifiable(hosts)));
    } catch (error) {
      emit(state.copyWith(error: error));
    }
  }

  Future<void> _onDelete(
    VncHostDelete event,
    Emitter<VncHostState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
    try {
      await repository.deleteHost(event.host);
      final hosts = await repository.loadHosts();
      emit(state.copyWith(hosts: List.unmodifiable(hosts)));
    } catch (error) {
      emit(state.copyWith(error: error));
    }
  }

  Future<void> _onMarkConnected(
    VncHostMarkConnected event,
    Emitter<VncHostState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
    try {
      await repository.markConnected(event.id);
      final hosts = await repository.loadHosts();
      emit(state.copyWith(hosts: List.unmodifiable(hosts)));
    } catch (error) {
      emit(state.copyWith(error: error));
    }
  }

  Future<void> _onDiscoverLan(
    VncHostDiscoverLan event,
    Emitter<VncHostState> emit,
  ) async {
    final generation = ++_discoveryGeneration;
    await _cancelDiscovery();

    if (isClosed || generation != _discoveryGeneration) {
      return;
    }

    emit(
      state.copyWith(
        isDiscovering: true,
        discoveredHosts: const [],
        clearError: true,
      ),
    );

    try {
      final stream = _discovery.discover(timeout: event.timeout);
      if (isClosed || generation != _discoveryGeneration) {
        return;
      }

      _discoverySubscription = stream.listen(
        (discovered) {
          if (!isClosed && generation == _discoveryGeneration) {
            add(
              _VncLanHostDiscovered(host: discovered, generation: generation),
            );
          }
        },
        onError: (Object error, StackTrace _) {
          if (!isClosed && generation == _discoveryGeneration) {
            add(_VncLanDiscoveryFailed(error: error, generation: generation));
          }
        },
        onDone: () {
          if (!isClosed && generation == _discoveryGeneration) {
            add(_VncLanDiscoveryCompleted(generation: generation));
          }
        },
        cancelOnError: true,
      );
    } catch (error) {
      if (generation == _discoveryGeneration) {
        emit(state.copyWith(isDiscovering: false, error: error));
      }
    }
  }

  void _onLanHostDiscovered(
    _VncLanHostDiscovered event,
    Emitter<VncHostState> emit,
  ) {
    if (event.generation != _discoveryGeneration) {
      return;
    }
    if (state.discoveredHosts.any((h) => h.id == event.host.id)) {
      return;
    }
    emit(
      state.copyWith(
        discoveredHosts: List<VncDiscoveredHost>.unmodifiable([
          ...state.discoveredHosts,
          event.host,
        ]),
      ),
    );
  }

  void _onLanDiscoveryFailed(
    _VncLanDiscoveryFailed event,
    Emitter<VncHostState> emit,
  ) {
    if (event.generation != _discoveryGeneration) {
      return;
    }
    _discoverySubscription = null;
    emit(state.copyWith(isDiscovering: false, error: event.error));
  }

  void _onLanDiscoveryCompleted(
    _VncLanDiscoveryCompleted event,
    Emitter<VncHostState> emit,
  ) {
    if (event.generation != _discoveryGeneration) {
      return;
    }
    _discoverySubscription = null;
    emit(state.copyWith(isDiscovering: false));
  }

  Future<void> _cancelDiscovery() async {
    final sub = _discoverySubscription;
    _discoverySubscription = null;
    if (sub != null) {
      try {
        await sub.cancel();
      } catch (_) {
        // Ignore cancellation errors from the underlying discovery stream.
      }
    }
  }

  @override
  Future<void> close() async {
    _discoveryGeneration++;
    try {
      await _cancelDiscovery();
    } finally {
      await super.close();
    }
  }
}
