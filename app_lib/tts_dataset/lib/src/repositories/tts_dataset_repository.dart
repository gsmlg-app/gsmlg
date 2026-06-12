import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

import '../models/audio_clip.dart';
import '../models/speaker_profile.dart';
import '../models/training_text_item.dart';
import '../models/tts_dataset_project.dart';
import '../models/validation_issue.dart';

class TtsDatasetRepository {
  TtsDatasetRepository(this._database);

  final AppDatabase _database;
  var _idCounter = 0;

  Future<TtsDatasetProjectDetail> createProject({
    required String name,
    required String targetProfile,
    required String language,
    required String speakerDisplayName,
    required String datasetLicense,
    required String consentStatus,
    required String rootPath,
    required String defaultNoiseReductionMode,
    List<String> starterPrompts = const [],
  }) async {
    final now = DateTime.now().toUtc();
    final projectId = _nextId('tts_project');
    final speakerId = _nextId('speaker');

    await _database
        .into(_database.ttsDatasetProjectTable)
        .insert(
          TtsDatasetProjectTableCompanion.insert(
            id: projectId,
            name: name.trim(),
            targetProfile: targetProfile,
            language: language,
            speakerId: speakerId,
            rootPath: rootPath,
            status: ProjectStatus.draft,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await _database
        .into(_database.ttsDatasetSpeakerTable)
        .insert(
          TtsDatasetSpeakerTableCompanion.insert(
            id: speakerId,
            projectId: projectId,
            displayName: speakerDisplayName.trim(),
            consentStatus: consentStatus,
            allowedUse: 'fine_tune_tts',
            datasetLicense: datasetLicense,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    for (final entry in starterPrompts.indexed) {
      await addPrompt(
        projectId: projectId,
        rawText: entry.$2,
        language: language,
        tags: const ['starter'],
        sortOrder: entry.$1,
      );
    }

    return (await loadProject(projectId))!;
  }

  Future<List<TtsDatasetProject>> listProjects() async {
    final rows = await (_database.select(
      _database.ttsDatasetProjectTable,
    )..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])).get();
    return rows.map(_projectFromRow).toList(growable: false);
  }

  Future<TtsDatasetProjectDetail?> loadProject(String projectId) async {
    final projectRow = await (_database.select(
      _database.ttsDatasetProjectTable,
    )..where((table) => table.id.equals(projectId))).getSingleOrNull();
    if (projectRow == null) return null;

    final speakerRow = await (_database.select(
      _database.ttsDatasetSpeakerTable,
    )..where((table) => table.projectId.equals(projectId))).getSingle();
    final prompts =
        await (_database.select(_database.ttsDatasetPromptTable)
              ..where((table) => table.projectId.equals(projectId))
              ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
            .get();
    final clips =
        await (_database.select(_database.ttsDatasetClipTable)
              ..where((table) => table.projectId.equals(projectId))
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();
    final issues = await (_database.select(
      _database.ttsDatasetValidationIssueTable,
    )..where((table) => table.projectId.equals(projectId))).get();

    return TtsDatasetProjectDetail(
      project: _projectFromRow(projectRow),
      speaker: _speakerFromRow(speakerRow),
      prompts: prompts.map(_promptFromRow).toList(growable: false),
      clips: clips.map(_clipFromRow).toList(growable: false),
      issues: issues.map(_issueFromRow).toList(growable: false),
    );
  }

  Future<TrainingTextItem> addPrompt({
    required String projectId,
    required String rawText,
    required String language,
    List<String> tags = const [],
    int? sortOrder,
  }) async {
    final now = DateTime.now().toUtc();
    final item = TrainingTextItem(
      id: _nextId('prompt'),
      projectId: projectId,
      rawText: rawText,
      normalizedText: _normalizeText(rawText),
      language: language,
      tags: tags,
      sortOrder: sortOrder ?? 0,
      status: PromptStatus.newPrompt,
      createdAt: now,
      updatedAt: now,
    );
    await _database
        .into(_database.ttsDatasetPromptTable)
        .insert(
          TtsDatasetPromptTableCompanion.insert(
            id: item.id,
            projectId: projectId,
            rawText: item.rawText,
            normalizedText: item.normalizedText,
            language: item.language,
            tags: item.tags,
            sortOrder: item.sortOrder,
            status: item.status,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return item;
  }

  Future<AudioClip> addManualClip({
    required String projectId,
    required String speakerId,
    required String rawPath,
    required String processedPath,
    required String exportWavPath,
    required String rawText,
    required String normalizedText,
    required String language,
    required int durationMs,
    required int sampleRate,
    required int channels,
    required int bitDepth,
    required String noiseReductionMode,
    required String status,
    String? promptId,
  }) async {
    final now = DateTime.now().toUtc();
    final clip = AudioClip(
      id: _nextId('clip'),
      projectId: projectId,
      speakerId: speakerId,
      promptId: promptId,
      rawPath: rawPath,
      processedPath: processedPath,
      exportWavPath: exportWavPath,
      rawText: rawText,
      normalizedText: _normalizeText(normalizedText),
      language: language,
      durationMs: durationMs,
      sampleRate: sampleRate,
      channels: channels,
      bitDepth: bitDepth,
      noiseReductionMode: noiseReductionMode,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
    await _database
        .into(_database.ttsDatasetClipTable)
        .insert(
          TtsDatasetClipTableCompanion.insert(
            id: clip.id,
            projectId: clip.projectId,
            speakerId: clip.speakerId,
            promptId: Value(clip.promptId),
            rawPath: clip.rawPath,
            processedPath: clip.processedPath,
            exportWavPath: clip.exportWavPath,
            rawText: clip.rawText,
            normalizedText: clip.normalizedText,
            language: clip.language,
            durationMs: clip.durationMs,
            sampleRate: clip.sampleRate,
            channels: clip.channels,
            bitDepth: clip.bitDepth,
            noiseReductionMode: clip.noiseReductionMode,
            status: clip.status,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return clip;
  }

  Future<void> selectReferenceClip(String projectId, String clipId) async {
    final now = DateTime.now().toUtc();
    await (_database.update(
      _database.ttsDatasetSpeakerTable,
    )..where((table) => table.projectId.equals(projectId))).write(
      TtsDatasetSpeakerTableCompanion(
        referenceClipId: Value(clipId),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateConsentStatus(String projectId, String consentStatus) {
    return (_database.update(
      _database.ttsDatasetSpeakerTable,
    )..where((table) => table.projectId.equals(projectId))).write(
      TtsDatasetSpeakerTableCompanion(
        consentStatus: Value(consentStatus),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> saveValidationIssues(
    String projectId,
    List<ValidationIssue> issues,
  ) async {
    await (_database.delete(
      _database.ttsDatasetValidationIssueTable,
    )..where((table) => table.projectId.equals(projectId))).go();
    for (final issue in issues) {
      await _database
          .into(_database.ttsDatasetValidationIssueTable)
          .insert(
            TtsDatasetValidationIssueTableCompanion.insert(
              id: issue.id,
              projectId: issue.projectId,
              clipId: Value(issue.clipId),
              category: issue.category,
              severity: issue.severity,
              code: issue.code,
              message: issue.message,
              suggestedFix: Value(issue.suggestedFix),
            ),
          );
    }
  }

  String _nextId(String prefix) {
    _idCounter += 1;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_idCounter';
  }

  String _normalizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  TtsDatasetProject _projectFromRow(TtsDatasetProjectTableData row) {
    return TtsDatasetProject(
      id: row.id,
      name: row.name,
      targetProfile: row.targetProfile,
      language: row.language,
      speakerId: row.speakerId,
      rootPath: row.rootPath,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SpeakerProfile _speakerFromRow(TtsDatasetSpeakerTableData row) {
    return SpeakerProfile(
      id: row.id,
      projectId: row.projectId,
      displayName: row.displayName,
      consentStatus: row.consentStatus,
      allowedUse: row.allowedUse,
      datasetLicense: row.datasetLicense,
      consentDocumentPath: row.consentDocumentPath,
      referenceClipId: row.referenceClipId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  TrainingTextItem _promptFromRow(TtsDatasetPromptTableData row) {
    return TrainingTextItem(
      id: row.id,
      projectId: row.projectId,
      rawText: row.rawText,
      normalizedText: row.normalizedText,
      language: row.language,
      tags: row.tags,
      sortOrder: row.sortOrder,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  AudioClip _clipFromRow(TtsDatasetClipTableData row) {
    return AudioClip(
      id: row.id,
      projectId: row.projectId,
      speakerId: row.speakerId,
      promptId: row.promptId,
      rawPath: row.rawPath,
      processedPath: row.processedPath,
      exportWavPath: row.exportWavPath,
      rawText: row.rawText,
      normalizedText: row.normalizedText,
      language: row.language,
      durationMs: row.durationMs,
      sampleRate: row.sampleRate,
      channels: row.channels,
      bitDepth: row.bitDepth,
      peakDb: row.peakDb,
      rmsDb: row.rmsDb,
      noiseFloorDb: row.noiseFloorDb,
      snrEstimateDb: row.snrEstimateDb,
      clippingCount: row.clippingCount,
      leadingSilenceMs: row.leadingSilenceMs,
      trailingSilenceMs: row.trailingSilenceMs,
      noiseReductionMode: row.noiseReductionMode,
      noiseReductionEngine: row.noiseReductionEngine,
      processingProfileId: row.processingProfileId,
      status: row.status,
      rejectionReason: row.rejectionReason,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ValidationIssue _issueFromRow(TtsDatasetValidationIssueTableData row) {
    return ValidationIssue(
      id: row.id,
      projectId: row.projectId,
      clipId: row.clipId,
      category: row.category,
      severity: row.severity,
      code: row.code,
      message: row.message,
      suggestedFix: row.suggestedFix,
    );
  }
}
