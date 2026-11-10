import 'package:app_agent/app_agent.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory [AgentRepository] for bloc tests that do not need a database.
class FakeAgentRepository implements AgentRepository {
  FakeAgentRepository([Iterable<AgentDefinition> seed = const []]) {
    for (final agent in seed) {
      agents[agent.id] = agent;
    }
  }

  final agents = <String, AgentDefinition>{};

  @override
  Future<List<AgentDefinition>> list() async => agents.values.toList();

  @override
  Future<AgentDefinition?> get(String id) async => agents[id];

  @override
  Future<void> save(AgentDefinition agent) async => agents[agent.id] = agent;

  @override
  Future<void> delete(String id) async => agents.remove(id);

  @override
  Future<void> importLegacy(SharedPreferences prefs) async {}
}
