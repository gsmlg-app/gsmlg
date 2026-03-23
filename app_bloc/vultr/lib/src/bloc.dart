import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vultr_api/api.dart';

part 'event.dart';
part 'state.dart';

class VultrBloc extends Bloc<VultrEvent, VultrState> {
  VultrBloc({required VaultRepository vault})
    : _vault = vault,
      super(const VultrInitial()) {
    on<VultrLoad>(_onLoad);
    on<VultrConnect>(_onConnect);
    on<VultrDisconnect>(_onDisconnect);
    on<VultrRefresh>(_onRefresh);
    on<VultrStartInstance>(_onStart);
    on<VultrStopInstance>(_onStop);
    on<VultrRebootInstance>(_onReboot);
  }

  final VaultRepository _vault;
  ApiClient? _apiClient;
  InstancesApi? _api;

  static const String _apiKeyKey = 'vultr_api_key';

  void _initApi(String apiKey) {
    final auth = HttpBearerAuth()..accessToken = apiKey;
    _apiClient = ApiClient(authentication: auth);
    _api = InstancesApi(_apiClient!);
  }

  Future<void> _onLoad(VultrLoad event, Emitter<VultrState> emit) async {
    emit(const VultrLoading());

    try {
      final apiKey = await _vault.read(key: _apiKeyKey);
      if (apiKey == null || apiKey.isEmpty) {
        emit(const VultrDisconnected());
        return;
      }

      _initApi(apiKey);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(VultrLoaded(instances: instances, apiKey: apiKey));
    } catch (e) {
      _apiClient = null;
      _api = null;
      emit(VultrError(message: e.toString()));
    }
  }

  Future<void> _onConnect(VultrConnect event, Emitter<VultrState> emit) async {
    emit(const VultrLoading());

    try {
      _initApi(event.apiKey);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];

      await _vault.write(key: _apiKeyKey, value: event.apiKey);
      emit(VultrLoaded(instances: instances, apiKey: event.apiKey));
    } catch (e) {
      _apiClient = null;
      _api = null;
      final message = e.toString();
      if (message.contains('401') || message.contains('403')) {
        emit(const VultrError(message: 'Invalid API key'));
      } else {
        emit(VultrError(message: 'Failed to connect: $message'));
      }
    }
  }

  Future<void> _onDisconnect(
    VultrDisconnect event,
    Emitter<VultrState> emit,
  ) async {
    emit(const VultrLoading());

    try {
      _apiClient = null;
      _api = null;
      await _vault.delete(key: _apiKeyKey);
      emit(const VultrDisconnected());
    } catch (e) {
      emit(VultrError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(VultrRefresh event, Emitter<VultrState> emit) async {
    final currentState = state;
    if (currentState is! VultrLoaded) return;

    emit(
      VultrLoaded(
        instances: currentState.instances,
        apiKey: currentState.apiKey,
        refreshing: true,
      ),
    );

    try {
      if (_api == null) _initApi(currentState.apiKey);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(VultrLoaded(instances: instances, apiKey: currentState.apiKey));
    } catch (e) {
      emit(VultrError(message: e.toString()));
    }
  }

  Future<void> _onStart(
    VultrStartInstance event,
    Emitter<VultrState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VultrLoaded) return;

    emit(
      VultrLoaded(
        instances: currentState.instances,
        apiKey: currentState.apiKey,
        actionInstanceId: event.instanceId,
      ),
    );

    try {
      await _api!.startInstance(event.instanceId);
      // Refresh instances list after action
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(VultrLoaded(instances: instances, apiKey: currentState.apiKey));
    } catch (e) {
      emit(
        VultrLoaded(
          instances: currentState.instances,
          apiKey: currentState.apiKey,
          error: 'Failed to start: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStop(
    VultrStopInstance event,
    Emitter<VultrState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VultrLoaded) return;

    emit(
      VultrLoaded(
        instances: currentState.instances,
        apiKey: currentState.apiKey,
        actionInstanceId: event.instanceId,
      ),
    );

    try {
      await _api!.haltInstance(event.instanceId);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(VultrLoaded(instances: instances, apiKey: currentState.apiKey));
    } catch (e) {
      emit(
        VultrLoaded(
          instances: currentState.instances,
          apiKey: currentState.apiKey,
          error: 'Failed to stop: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onReboot(
    VultrRebootInstance event,
    Emitter<VultrState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VultrLoaded) return;

    emit(
      VultrLoaded(
        instances: currentState.instances,
        apiKey: currentState.apiKey,
        actionInstanceId: event.instanceId,
      ),
    );

    try {
      await _api!.rebootInstance(event.instanceId);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(VultrLoaded(instances: instances, apiKey: currentState.apiKey));
    } catch (e) {
      emit(
        VultrLoaded(
          instances: currentState.instances,
          apiKey: currentState.apiKey,
          error: 'Failed to reboot: ${e.toString()}',
        ),
      );
    }
  }
}
