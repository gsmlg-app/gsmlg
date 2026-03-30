import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vultr_api/api.dart';

part 'event.dart';
part 'state.dart';

class VultrBloc extends Bloc<VultrEvent, VultrState> {
  VultrBloc({required VaultRepository vault, required AppDatabase database})
    : _vault = vault,
      _database = database,
      super(const VultrInitial()) {
    on<VultrSelectAccount>(_onSelectAccount);
    on<VultrRefresh>(_onRefresh);
    on<VultrStartInstance>(_onStart);
    on<VultrStopInstance>(_onStop);
    on<VultrRebootInstance>(_onReboot);
  }

  final VaultRepository _vault;
  final AppDatabase _database;
  ApiClient? _apiClient;
  InstancesApi? _api;

  void _initApi(String apiKey) {
    final auth = HttpBearerAuth()..accessToken = apiKey;
    _apiClient = ApiClient(authentication: auth);
    _api = InstancesApi(_apiClient!);
  }

  Future<String> _getApiKey(int accountId) async {
    final key = 'service_account_$accountId';
    final apiKey = await _vault.read(key: key);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No API key found for this account');
    }
    return apiKey;
  }

  /// Get all Vultr service accounts from the database.
  Future<List<ServiceAccountTableData>> getVultrAccounts() async {
    final query = _database.select(_database.serviceAccountTable)
      ..where((t) => t.provider.equals(ServiceProvider.vultr.name));
    return query.get();
  }

  Future<void> _onSelectAccount(
    VultrSelectAccount event,
    Emitter<VultrState> emit,
  ) async {
    emit(const VultrLoading());

    try {
      final apiKey = await _getApiKey(event.accountId);
      _initApi(apiKey);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(VultrLoaded(instances: instances, accountId: event.accountId));
    } catch (e) {
      _apiClient = null;
      _api = null;
      emit(VultrError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(VultrRefresh event, Emitter<VultrState> emit) async {
    final currentState = state;
    if (currentState is! VultrLoaded) return;

    emit(
      VultrLoaded(
        instances: currentState.instances,
        accountId: currentState.accountId,
        refreshing: true,
      ),
    );

    try {
      if (_api == null) {
        final apiKey = await _getApiKey(currentState.accountId);
        _initApi(apiKey);
      }
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(
        VultrLoaded(instances: instances, accountId: currentState.accountId),
      );
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
        accountId: currentState.accountId,
        actionInstanceId: event.instanceId,
      ),
    );

    try {
      await _api!.startInstance(event.instanceId);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(
        VultrLoaded(instances: instances, accountId: currentState.accountId),
      );
    } catch (e) {
      emit(
        VultrLoaded(
          instances: currentState.instances,
          accountId: currentState.accountId,
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
        accountId: currentState.accountId,
        actionInstanceId: event.instanceId,
      ),
    );

    try {
      await _api!.haltInstance(event.instanceId);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(
        VultrLoaded(instances: instances, accountId: currentState.accountId),
      );
    } catch (e) {
      emit(
        VultrLoaded(
          instances: currentState.instances,
          accountId: currentState.accountId,
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
        accountId: currentState.accountId,
        actionInstanceId: event.instanceId,
      ),
    );

    try {
      await _api!.rebootInstance(event.instanceId);
      final response = await _api!.listInstances();
      final instances = response?.instances ?? <InstanceGet>[];
      emit(
        VultrLoaded(instances: instances, accountId: currentState.accountId),
      );
    } catch (e) {
      emit(
        VultrLoaded(
          instances: currentState.instances,
          accountId: currentState.accountId,
          error: 'Failed to reboot: ${e.toString()}',
        ),
      );
    }
  }
}
