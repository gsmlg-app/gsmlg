library;

export 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show PlatformInt64, PlatformInt64Util;

export 'src/app_duckdb.dart';
export 'src/duckdb_log_output.dart';
export 'src/duckdb_log_sink.dart';
export 'src/log_query_builder.dart';
export 'src/log_router.dart';
export 'src/models/log_record_item.dart';
export 'src/rust/api/duckdb.dart'
    show
        AgentEventEntry,
        ApiExchangeEntry,
        SystemLogEntry,
        UsageEventEntry,
        openDuckdb,
        closeDuckdb,
        isDuckdbOpen,
        executeSql,
        ensureLogSchemas,
        batchAppendSystemLogs,
        batchAppendApiExchanges,
        batchAppendAgentEvents,
        batchAppendUsageEvents,
        querySystemLogs,
        querySqlJson;
export 'src/rust/frb_generated.dart' show RustLib;
