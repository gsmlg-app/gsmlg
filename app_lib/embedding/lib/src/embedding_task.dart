/// EmbeddingGemma 2 task instructions. The model is trained with these text
/// prefixes; asymmetric tasks embed queries and documents differently.
enum EmbeddingTask {
  search('search result'),
  questionAnswering('question answering'),
  factChecking('fact checking'),
  codeRetrieval('code retrieval'),
  classification('classification'),
  clustering('clustering'),
  similarity('sentence similarity');

  const EmbeddingTask(this.instruction);

  final String instruction;

  /// Query side of an asymmetric task, or either side of a symmetric one.
  String formatQuery(String text) => 'task: $instruction | query: $text';

  /// Corpus side of an asymmetric task. [title] is a document title, file
  /// name or `null` when unknown.
  static String formatDocument(String text, {String? title}) =>
      'title: ${title == null || title.trim().isEmpty ? 'none' : title} | text: $text';
}
