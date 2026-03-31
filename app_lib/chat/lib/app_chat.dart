/// Core chat library with models and repositories for on-device LLM chat.
library;

// Models
export 'src/models/message.dart';
export 'src/models/conversation.dart';
export 'src/models/model_config.dart';

// Repositories
export 'src/repositories/gemma_repository.dart';
export 'src/repositories/chat_storage_repository.dart';

// Services
export 'src/services/tool_executor.dart';
