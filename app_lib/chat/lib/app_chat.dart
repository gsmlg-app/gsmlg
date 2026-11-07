/// Core chat library with models and repositories for on-device LLM chat.
library;

// Models
export 'src/models/message.dart';
export 'src/models/conversation.dart';
export 'src/models/model_config.dart';
export 'src/models/backplane_settings.dart';
export 'src/models/inference.dart';
export 'src/models/agent_metadata.dart';

// Agent Runtime
export 'src/agent/agent_event.dart';
export 'src/agent/agent_invocation.dart';
export 'src/agent/chat_agent_runtime.dart';
export 'src/agent/memory_provider.dart';
export 'src/agent/plugin_consumer.dart';
export 'src/agent/repository_agent_llm_client.dart';
export 'src/agent/shell_service.dart';
export 'src/agent/skill_registry.dart';
export 'src/agent/sub_agent_supervisor.dart';
export 'src/agent/tool_gateway.dart';

export 'package:dio/dio.dart' show CancelToken;
export 'package:dart_agent_core/dart_agent_core.dart'
    show AgentException, AgentExceptionCode;

// Repositories
export 'src/repositories/gemma_repository.dart';
export 'src/repositories/local_model_access.dart';
export 'src/repositories/chat_storage_repository.dart';
export 'src/repositories/remote_llm_repository.dart';
export 'src/repositories/backplane_service_repository.dart';

// Services
export 'src/services/dart_mcp_tool_client.dart';
export 'src/services/tool_executor.dart';

export 'src/services/conversation_title_generator.dart';
export 'src/services/minicpm_title_backend.dart';
