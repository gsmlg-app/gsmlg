class DatasetExportRequest {
  const DatasetExportRequest({
    required this.projectId,
    required this.outputPath,
  });

  final String projectId;
  final String outputPath;
}

class DatasetExportResult {
  const DatasetExportResult({
    required this.projectId,
    required this.outputPath,
    required this.sha256Hex,
    required this.entryCount,
  });

  final String projectId;
  final String outputPath;
  final String sha256Hex;
  final int entryCount;
}
