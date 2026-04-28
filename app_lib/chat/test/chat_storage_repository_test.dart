import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists remote thinking effort with chat settings', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    final repository = ChatStorageRepository(database);
    const config = ModelConfig(
      inferenceMode: ChatInferenceMode.remote,
      remoteProvider: RemoteLlmProvider.deepSeek,
      remoteAccountId: ModelConfig.dummyRemoteAccountId,
      remoteBaseUrl: 'https://api.deepseek.com/v1',
      remoteModel: 'deepseek-v4-pro',
      remoteThinkingEffort: RemoteThinkingEffort.max,
    );

    await repository.saveSettings(config);

    expect(await repository.loadSettings(), config);
  });
}
