use duckdb::{params, Connection};
use parking_lot::Mutex;
use serde::{Deserialize, Serialize};

static DB_CONN: Mutex<Option<Connection>> = Mutex::new(None);

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SystemLogEntry {
    pub id: String,
    pub timestamp_us: i64,
    pub level: String,
    pub logger_name: Option<String>,
    pub message: String,
    pub isolate_id: Option<String>,
    pub error: Option<String>,
    pub stack_trace: Option<String>,
    pub metadata: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApiExchangeEntry {
    pub id: String,
    pub timestamp_us: i64,
    pub request_id: String,
    pub record_type: String,
    pub category: String,
    pub api_type: Option<String>,
    pub method: Option<String>,
    pub host: Option<String>,
    pub path: Option<String>,
    pub status: Option<i32>,
    pub duration_ms: Option<i32>,
    pub has_error: bool,
    pub aborted: bool,
    pub conversation_id: Option<String>,
    pub run_id: Option<String>,
    pub turn: Option<i32>,
    pub tool_call_id: Option<String>,
    pub record_json: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentEventEntry {
    pub id: String,
    pub timestamp_us: i64,
    pub event_type: String,
    pub conversation_id: Option<String>,
    pub run_id: Option<String>,
    pub parent_run_id: Option<String>,
    pub turn: Option<i32>,
    pub tool_call_id: Option<String>,
    pub tool_name: Option<String>,
    pub backend: Option<String>,
    pub request_id: Option<String>,
    pub level: String,
    pub is_error: bool,
    pub duration_ms: Option<i32>,
    pub summary: String,
    pub payload_json: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UsageEventEntry {
    pub id: String,
    pub timestamp_us: i64,
    pub session_id: String,
    pub event_type: String,
    pub module: Option<String>,
    pub screen_name: Option<String>,
    pub route_path: Option<String>,
    pub target: Option<String>,
    pub source_screen: Option<String>,
    pub duration_ms: Option<i64>,
    pub payload_json: Option<String>,
}

/// Open DuckDB database at given file path or in-memory if None or ":memory:".
pub fn open_duckdb(path: Option<String>) -> Result<(), String> {
    let mut lock = DB_CONN.lock();
    let conn = match path {
        Some(ref p) if !p.is_empty() && p != ":memory:" => {
            Connection::open(p).map_err(|e| format!("Failed to open DuckDB at {p}: {e}"))?
        }
        _ => Connection::open_in_memory()
            .map_err(|e| format!("Failed to open in-memory DuckDB: {e}"))?,
    };
    *lock = Some(conn);
    Ok(())
}

/// Close current DuckDB connection if open.
pub fn close_duckdb() -> Result<(), String> {
    let mut lock = DB_CONN.lock();
    *lock = None;
    Ok(())
}

/// Check if DuckDB connection is currently active.
pub fn is_duckdb_open() -> bool {
    DB_CONN.lock().is_some()
}

/// Execute arbitrary DDL/DML statement (e.g. CREATE TABLE, INSERT).
pub fn execute_sql(sql: String) -> Result<usize, String> {
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    conn.execute(&sql, []).map_err(|e| format!("SQL error: {e}"))
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

/// Ensure log tables (`system_logs`, `api_exchanges`, `agent_events`,
/// `usage_events`) and the `v_all_logs` view exist. Drops legacy objects first.
pub fn ensure_log_schemas() -> Result<(), String> {
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;

    conn.execute_batch(
        "DROP VIEW IF EXISTS v_all_logs;
        DROP TABLE IF EXISTS dns_logs;
        DROP TABLE IF EXISTS dhcp_logs;
        DROP TABLE IF EXISTS app_logs;

        CREATE TABLE IF NOT EXISTS system_logs (
            id VARCHAR PRIMARY KEY,
            timestamp_us BIGINT,
            level VARCHAR,
            logger_name VARCHAR,
            message TEXT,
            isolate_id VARCHAR,
            error TEXT,
            stack_trace TEXT,
            metadata TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_sys_logs_time ON system_logs(timestamp_us DESC);
        CREATE INDEX IF NOT EXISTS idx_sys_logs_level ON system_logs(level);

        CREATE TABLE IF NOT EXISTS api_exchanges (
            id VARCHAR PRIMARY KEY,
            timestamp_us BIGINT,
            request_id VARCHAR,
            record_type VARCHAR,
            category VARCHAR,
            api_type VARCHAR,
            method VARCHAR,
            host VARCHAR,
            path VARCHAR,
            status INTEGER,
            duration_ms INTEGER,
            has_error BOOLEAN,
            aborted BOOLEAN,
            conversation_id VARCHAR,
            run_id VARCHAR,
            turn INTEGER,
            tool_call_id VARCHAR,
            record_json TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_api_exchanges_time ON api_exchanges(timestamp_us DESC);
        CREATE INDEX IF NOT EXISTS idx_api_exchanges_category ON api_exchanges(category);

        CREATE TABLE IF NOT EXISTS agent_events (
            id VARCHAR PRIMARY KEY,
            timestamp_us BIGINT,
            event_type VARCHAR,
            conversation_id VARCHAR,
            run_id VARCHAR,
            parent_run_id VARCHAR,
            turn INTEGER,
            tool_call_id VARCHAR,
            tool_name VARCHAR,
            backend VARCHAR,
            request_id VARCHAR,
            level VARCHAR,
            is_error BOOLEAN,
            duration_ms INTEGER,
            summary TEXT,
            payload_json TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_agent_events_time ON agent_events(timestamp_us DESC);
        CREATE INDEX IF NOT EXISTS idx_agent_events_run ON agent_events(run_id);

        CREATE TABLE IF NOT EXISTS usage_events (
            id VARCHAR PRIMARY KEY,
            timestamp_us BIGINT,
            session_id VARCHAR,
            event_type VARCHAR,
            module VARCHAR,
            screen_name VARCHAR,
            route_path VARCHAR,
            target VARCHAR,
            source_screen VARCHAR,
            duration_ms BIGINT,
            payload_json TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_usage_events_time ON usage_events(timestamp_us DESC);
        CREATE INDEX IF NOT EXISTS idx_usage_events_session ON usage_events(session_id);

        CREATE VIEW v_all_logs AS
        SELECT id, timestamp_us, 'system' AS log_type, 'system' AS category,
               level, logger_name, message FROM system_logs
        UNION ALL
        SELECT id, timestamp_us, 'api' AS log_type, category,
               CASE WHEN has_error OR coalesce(status, 0) >= 400 THEN 'SEVERE' ELSE 'INFO' END AS level,
               'api' AS logger_name,
               concat(method, ' ', host, path, ' → ', coalesce(CAST(status AS VARCHAR), 'ERR')) AS message
        FROM api_exchanges
        UNION ALL
        SELECT id, timestamp_us, 'agent' AS log_type, 'agent' AS category,
               level, 'agent' AS logger_name, summary AS message FROM agent_events;
        ",
    )
    .map_err(|e| format!("Failed to create log schemas: {e}"))?;

    Ok(())
}

/// Batch append entries to `system_logs`.
pub fn batch_append_system_logs(entries: Vec<SystemLogEntry>) -> Result<usize, String> {
    if entries.is_empty() {
        return Ok(0);
    }
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let count = entries.len();
    let mut appender = conn
        .appender("system_logs")
        .map_err(|e| format!("Failed to create system_logs appender: {e}"))?;

    for e in entries {
        appender
            .append_row(params![
                e.id,
                e.timestamp_us,
                e.level,
                e.logger_name,
                e.message,
                e.isolate_id,
                e.error,
                e.stack_trace,
                e.metadata,
            ])
            .map_err(|e| format!("Failed to append system_log row: {e}"))?;
    }
    appender
        .flush()
        .map_err(|e| format!("Failed to flush system_logs appender: {e}"))?;
    Ok(count)
}

/// Batch append entries to `api_exchanges`.
pub fn batch_append_api_exchanges(entries: Vec<ApiExchangeEntry>) -> Result<usize, String> {
    if entries.is_empty() {
        return Ok(0);
    }
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let count = entries.len();
    let mut appender = conn
        .appender("api_exchanges")
        .map_err(|e| format!("Failed to create api_exchanges appender: {e}"))?;

    for e in entries {
        appender
            .append_row(params![
                e.id,
                e.timestamp_us,
                e.request_id,
                e.record_type,
                e.category,
                e.api_type,
                e.method,
                e.host,
                e.path,
                e.status,
                e.duration_ms,
                e.has_error,
                e.aborted,
                e.conversation_id,
                e.run_id,
                e.turn,
                e.tool_call_id,
                e.record_json,
            ])
            .map_err(|e| format!("Failed to append api_exchanges row: {e}"))?;
    }
    appender
        .flush()
        .map_err(|e| format!("Failed to flush api_exchanges appender: {e}"))?;
    Ok(count)
}

/// Batch append entries to `agent_events`.
pub fn batch_append_agent_events(entries: Vec<AgentEventEntry>) -> Result<usize, String> {
    if entries.is_empty() {
        return Ok(0);
    }
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let count = entries.len();
    let mut appender = conn
        .appender("agent_events")
        .map_err(|e| format!("Failed to create agent_events appender: {e}"))?;

    for e in entries {
        appender
            .append_row(params![
                e.id,
                e.timestamp_us,
                e.event_type,
                e.conversation_id,
                e.run_id,
                e.parent_run_id,
                e.turn,
                e.tool_call_id,
                e.tool_name,
                e.backend,
                e.request_id,
                e.level,
                e.is_error,
                e.duration_ms,
                e.summary,
                e.payload_json,
            ])
            .map_err(|e| format!("Failed to append agent_events row: {e}"))?;
    }
    appender
        .flush()
        .map_err(|e| format!("Failed to flush agent_events appender: {e}"))?;
    Ok(count)
}

/// Batch append entries to `usage_events`.
pub fn batch_append_usage_events(entries: Vec<UsageEventEntry>) -> Result<usize, String> {
    if entries.is_empty() {
        return Ok(0);
    }
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let count = entries.len();
    let mut appender = conn
        .appender("usage_events")
        .map_err(|e| format!("Failed to create usage_events appender: {e}"))?;

    for e in entries {
        appender
            .append_row(params![
                e.id,
                e.timestamp_us,
                e.session_id,
                e.event_type,
                e.module,
                e.screen_name,
                e.route_path,
                e.target,
                e.source_screen,
                e.duration_ms,
                e.payload_json,
            ])
            .map_err(|e| format!("Failed to append usage_events row: {e}"))?;
    }
    appender
        .flush()
        .map_err(|e| format!("Failed to flush usage_events appender: {e}"))?;
    Ok(count)
}

/// Query system logs with optional level filter and limit.
pub fn query_system_logs(
    limit: Option<u32>,
    level: Option<String>,
) -> Result<Vec<SystemLogEntry>, String> {
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let lim = limit.unwrap_or(100);

    let (sql, filter_val) = match level {
        Some(lvl) if !lvl.is_empty() => (
            "SELECT id, timestamp_us, level, logger_name, message, isolate_id, error, stack_trace, metadata
             FROM system_logs WHERE level = ? ORDER BY timestamp_us DESC LIMIT ?;",
            Some(lvl),
        ),
        _ => (
            "SELECT id, timestamp_us, level, logger_name, message, isolate_id, error, stack_trace, metadata
             FROM system_logs ORDER BY timestamp_us DESC LIMIT ?;",
            None,
        ),
    };

    let mut stmt = conn.prepare(sql).map_err(|e| format!("Prepare error: {e}"))?;
    let mapper = |row: &duckdb::Row| -> duckdb::Result<SystemLogEntry> {
        Ok(SystemLogEntry {
            id: row.get(0)?,
            timestamp_us: row.get(1)?,
            level: row.get(2)?,
            logger_name: row.get(3)?,
            message: row.get(4)?,
            isolate_id: row.get(5)?,
            error: row.get(6)?,
            stack_trace: row.get(7)?,
            metadata: row.get(8)?,
        })
    };

    let rows: Vec<SystemLogEntry> = if let Some(lvl) = filter_val {
        let r = stmt
            .query_map(params![lvl, lim], mapper)
            .map_err(|e| format!("Query error: {e}"))?;
        let mut list = Vec::new();
        for item in r {
            list.push(item.map_err(|e| format!("Row error: {e}"))?);
        }
        list
    } else {
        let r = stmt
            .query_map(params![lim], mapper)
            .map_err(|e| format!("Query error: {e}"))?;
        let mut list = Vec::new();
        for item in r {
            list.push(item.map_err(|e| format!("Row error: {e}"))?);
        }
        list
    };

    Ok(rows)
}

/// Execute arbitrary SQL and return results as JSON array string.
pub fn query_sql_json(sql: String) -> Result<String, String> {
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;

    let mut stmt = conn.prepare(&sql).map_err(|e| format!("Prepare error: {e}"))?;
    let mut rows = stmt.query([]).map_err(|e| format!("Query error: {e}"))?;
    let mut results: Vec<serde_json::Map<String, serde_json::Value>> = Vec::new();
    let mut column_names: Option<Vec<String>> = None;

    while let Some(row) = rows.next().map_err(|e| format!("Row error: {e}"))? {
        let cols = column_names.get_or_insert_with(|| row.as_ref().column_names());
        let mut obj = serde_json::Map::new();
        for (i, name) in cols.iter().enumerate() {
            let val = match row.get_ref(i) {
                Ok(duckdb::types::ValueRef::Null) => serde_json::Value::Null,
                Ok(duckdb::types::ValueRef::Boolean(b)) => serde_json::Value::Bool(b),
                Ok(duckdb::types::ValueRef::TinyInt(n)) => serde_json::Value::from(n),
                Ok(duckdb::types::ValueRef::SmallInt(n)) => serde_json::Value::from(n),
                Ok(duckdb::types::ValueRef::Int(n)) => serde_json::Value::from(n),
                Ok(duckdb::types::ValueRef::BigInt(n)) => serde_json::Value::from(n),
                Ok(duckdb::types::ValueRef::HugeInt(n)) => serde_json::Value::from(n.to_string()),
                Ok(duckdb::types::ValueRef::Float(f)) => serde_json::json!(f),
                Ok(duckdb::types::ValueRef::Double(d)) => serde_json::json!(d),
                Ok(duckdb::types::ValueRef::Text(s)) => {
                    serde_json::Value::String(String::from_utf8_lossy(s).to_string())
                }
                Ok(duckdb::types::ValueRef::Blob(b)) => {
                    serde_json::Value::String(format!("<blob {} bytes>", b.len()))
                }
                Ok(other) => serde_json::Value::String(format!("{other:?}")),
                Err(_) => serde_json::Value::Null,
            };
            obj.insert(name.clone(), val);
        }
        results.push(obj);
    }

    serde_json::to_string(&results).map_err(|e| format!("JSON serialize error: {e}"))
}

