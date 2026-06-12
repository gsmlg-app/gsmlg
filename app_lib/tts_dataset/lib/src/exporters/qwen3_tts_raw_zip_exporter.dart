import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../models/audio_clip.dart';
import '../models/dataset_export.dart';
import '../models/tts_dataset_project.dart';
import '../models/validation_issue.dart';
import '../repositories/tts_dataset_repository.dart';
import '../services/tts_dataset_validation_service.dart';

class Qwen3TtsRawZipExporter {
  Qwen3TtsRawZipExporter(this._repository);

  final TtsDatasetRepository _repository;
  final TtsDatasetValidationService _validationService =
      const TtsDatasetValidationService();

  Future<DatasetExportResult> export(DatasetExportRequest request) async {
    final detail = await _repository.loadProject(request.projectId);
    if (detail == null) {
      throw StateError('TTS dataset project not found: ${request.projectId}');
    }

    final validation = _validationService.validate(
      detail,
      fileExists: (rootPath, relativePath) =>
          File(p.join(rootPath, relativePath)).existsSync(),
    );
    if (validation.hasErrors) {
      final codes = validation.errors.map((issue) => issue.code).join(', ');
      throw StateError('TTS dataset export blocked: $codes');
    }

    final accepted = detail.clips
        .where((clip) => clip.status == ClipStatus.accepted)
        .toList(growable: false);
    final referenceClip = accepted.singleWhere(
      (clip) => clip.id == detail.speaker.referenceClipId,
    );
    final rootName = p.basenameWithoutExtension(request.outputPath);
    final archive = Archive();
    final hashes = <String, String>{};

    void addBytes(String path, List<int> bytes) {
      final normalizedPath = p.posix.join(rootName, path);
      archive.addFile(ArchiveFile(normalizedPath, bytes.length, bytes));
      hashes[path] = sha256.convert(bytes).toString();
    }

    void addText(String path, String text) {
      addBytes(path, utf8.encode(text));
    }

    void addProjectFile(String exportPath, String projectRelativePath) {
      final file = File(p.join(detail.project.rootPath, projectRelativePath));
      addBytes(exportPath, file.readAsBytesSync());
    }

    addText('train_raw.jsonl', _trainRawJsonl(accepted));
    addText('README.md', _readme(detail));
    addText('consent/speaker_consent.json', _speakerConsentJson(detail));
    addText('text/prompts.csv', _promptsCsv(detail));
    addText('text/clips_transcripts.csv', _clipsCsv(accepted));
    addText('reports/validation_report.json', _validationReport(validation));
    addText('reports/quality_report.csv', _qualityReportCsv(accepted));
    addProjectFile('ref/ref.wav', referenceClip.exportWavPath);

    for (final clip in accepted) {
      addProjectFile(
        p.posix.join('wavs', p.basename(clip.exportWavPath)),
        clip.exportWavPath,
      );
      addProjectFile(
        p.posix.join('raw', p.basename(clip.rawPath)),
        clip.rawPath,
      );
    }

    addText(
      'manifest.json',
      _manifestJson(detail, accepted, validation, hashes),
    );

    final zipBytes = ZipEncoder().encode(archive);
    final output = File(request.outputPath);
    await output.parent.create(recursive: true);
    await output.writeAsBytes(zipBytes);

    return DatasetExportResult(
      projectId: request.projectId,
      outputPath: request.outputPath,
      sha256Hex: sha256.convert(zipBytes).toString(),
      entryCount: archive.files.length,
    );
  }

  String _trainRawJsonl(List<AudioClip> clips) {
    return clips
        .map((clip) {
          return jsonEncode({
            'audio': './wavs/${p.basename(clip.exportWavPath)}',
            'text': clip.normalizedText,
            'ref_audio': './ref/ref.wav',
          });
        })
        .join('\n');
  }

  String _manifestJson(
    TtsDatasetProjectDetail detail,
    List<AudioClip> accepted,
    ValidationResult validation,
    Map<String, String> hashes,
  ) {
    final acceptedDurationMs = accepted.fold<int>(
      0,
      (total, clip) => total + clip.durationMs,
    );
    return const JsonEncoder.withIndent('  ').convert({
      'schema_version': '1.0',
      'target_profile': detail.project.targetProfile,
      'created_by': 'GSMLG App',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'speaker': {
        'id': detail.speaker.id,
        'display_name': detail.speaker.displayName,
        'consent_status': detail.speaker.consentStatus,
        'allowed_use': detail.speaker.allowedUse,
        'dataset_license': detail.speaker.datasetLicense,
      },
      'audio': {
        'export_sample_rate': 24000,
        'channels': 1,
        'format': 'wav_pcm',
        'noise_reduction_default_mode': NoiseReductionMode.medium,
      },
      'dataset': {
        'accepted_clip_count': accepted.length,
        'accepted_duration_ms': acceptedDurationMs,
        'reference_audio': './ref/ref.wav',
        'training_jsonl': './train_raw.jsonl',
      },
      'validation_summary': {
        'errors': validation.errors.length,
        'warnings': validation.warnings.length,
      },
      'file_hashes': hashes,
    });
  }

  String _speakerConsentJson(TtsDatasetProjectDetail detail) {
    return const JsonEncoder.withIndent('  ').convert({
      'speaker_id': detail.speaker.id,
      'display_name': detail.speaker.displayName,
      'consent_status': detail.speaker.consentStatus,
      'allowed_use': detail.speaker.allowedUse,
      'dataset_license': detail.speaker.datasetLicense,
      'created_at': detail.speaker.createdAt.toUtc().toIso8601String(),
      'app_version': '1.0.0',
    });
  }

  String _validationReport(ValidationResult validation) {
    return const JsonEncoder.withIndent('  ').convert({
      'issues': validation.issues
          .map(
            (issue) => {
              'id': issue.id,
              'project_id': issue.projectId,
              'clip_id': issue.clipId,
              'category': issue.category,
              'severity': issue.severity,
              'code': issue.code,
              'message': issue.message,
              'suggested_fix': issue.suggestedFix,
            },
          )
          .toList(),
    });
  }

  String _promptsCsv(TtsDatasetProjectDetail detail) {
    final rows = ['id,text,language,tags,status'];
    for (final prompt in detail.prompts) {
      rows.add(
        [
          prompt.id,
          prompt.normalizedText,
          prompt.language,
          prompt.tags.join(','),
          prompt.status,
        ].map(_csv).join(','),
      );
    }
    return '${rows.join('\n')}\n';
  }

  String _clipsCsv(List<AudioClip> clips) {
    final rows = ['id,text,language,status,audio'];
    for (final clip in clips) {
      rows.add(
        [
          clip.id,
          clip.normalizedText,
          clip.language,
          clip.status,
          './wavs/${p.basename(clip.exportWavPath)}',
        ].map(_csv).join(','),
      );
    }
    return '${rows.join('\n')}\n';
  }

  String _qualityReportCsv(List<AudioClip> clips) {
    final rows = [
      'id,duration_ms,sample_rate,channels,bit_depth,peak_db,rms_db,noise_floor_db,snr_estimate_db,clipping_count',
    ];
    for (final clip in clips) {
      rows.add(
        [
          clip.id,
          clip.durationMs.toString(),
          clip.sampleRate.toString(),
          clip.channels.toString(),
          clip.bitDepth.toString(),
          clip.peakDb?.toString() ?? '',
          clip.rmsDb?.toString() ?? '',
          clip.noiseFloorDb?.toString() ?? '',
          clip.snrEstimateDb?.toString() ?? '',
          clip.clippingCount?.toString() ?? '',
        ].map(_csv).join(','),
      );
    }
    return '${rows.join('\n')}\n';
  }

  String _readme(TtsDatasetProjectDetail detail) {
    return [
      '# ${detail.project.name}',
      '',
      'This ZIP is a GSMLG Qwen3-TTS raw dataset export.',
      '',
      'Use `train_raw.jsonl` as the raw input for the official Qwen3-TTS data preparation script, then run Qwen fine-tuning outside the Flutter app.',
      '',
      'Every row uses `./ref/ref.wav` as the shared speaker reference.',
      '',
    ].join('\n');
  }

  String _csv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
