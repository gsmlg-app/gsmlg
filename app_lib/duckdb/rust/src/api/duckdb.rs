use duckdb::{params, Connection};
use parking_lot::Mutex;
use serde::{Deserialize, Serialize};

static DB_CONN: Mutex<Option<Connection>> = Mutex::new(None);

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DuckDbLogEntry {
    pub id: String,
    pub timestamp_us: i64,
    pub level: String,
    pub logger_name: Option<String>,
    pub message: String,
    pub query_type: Option<String>,
    pub domain: Option<String>,
    pub source_ip: Option<String>,
    pub status: Option<String>,
    pub latency_ms: Option<i32>,
    pub metadata: Option<String>,
}

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
pub struct DnsLogEntry {
    pub id: String,
    pub timestamp_us: i64,
    pub client_ip: Option<String>,
    pub client_port: Option<i32>,
    pub protocol: Option<String>,
    pub query_type: Option<String>,
    pub domain: Option<String>,
    pub rcode: Option<String>,
    pub answers: Option<String>,
    pub latency_ms: Option<i32>,
    pub cached: Option<bool>,
    pub upstream: Option<String>,
    pub status: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DhcpLogEntry {
    pub id: String,
    pub timestamp_us: i64,
    pub ip_version: Option<String>,
    pub message_type: Option<String>,
    pub client_mac: Option<String>,
    pub hostname: Option<String>,
    pub assigned_ip: Option<String>,
    pub lease_time_sec: Option<i32>,
    pub server_ip: Option<String>,
    pub interface_name: Option<String>,
    pub status: Option<String>,
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

/// Legacy single log schema for backward compatibility.
pub fn ensure_log_schema() -> Result<(), String> {
    execute_sql(
        "CREATE TABLE IF NOT EXISTS app_logs (
            id VARCHAR PRIMARY KEY,
            timestamp_us BIGINT,
            level VARCHAR,
            logger_name VARCHAR,
            message TEXT,
            query_type VARCHAR,
            domain VARCHAR,
            source_ip VARCHAR,
            status VARCHAR,
            latency_ms INTEGER,
            metadata TEXT
        );"
        .to_string(),
    )?;
    Ok(())
}

/// Ensure dedicated tables (`system_logs`, `dns_logs`, `dhcp_logs`) and view exist.
pub fn ensure_log_schemas() -> Result<(), String> {
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;

    conn.execute_batch(
        "CREATE TABLE IF NOT EXISTS system_logs (
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

        CREATE TABLE IF NOT EXISTS dns_logs (
            id VARCHAR PRIMARY KEY,
            timestamp_us BIGINT,
            client_ip VARCHAR,
            client_port INTEGER,
            protocol VARCHAR,
            query_type VARCHAR,
            domain VARCHAR,
            rcode VARCHAR,
            answers TEXT,
            latency_ms INTEGER,
            cached BOOLEAN,
            upstream VARCHAR,
            status VARCHAR
        );
        CREATE INDEX IF NOT EXISTS idx_dns_logs_time ON dns_logs(timestamp_us DESC);
        CREATE INDEX IF NOT EXISTS idx_dns_logs_domain ON dns_logs(domain);
        CREATE INDEX IF NOT EXISTS idx_dns_logs_client ON dns_logs(client_ip);
        CREATE INDEX IF NOT EXISTS idx_dns_logs_rcode ON dns_logs(rcode);

        CREATE TABLE IF NOT EXISTS dhcp_logs (
            id VARCHAR PRIMARY KEY,
            timestamp_us BIGINT,
            ip_version VARCHAR,
            message_type VARCHAR,
            client_mac VARCHAR,
            hostname VARCHAR,
            assigned_ip VARCHAR,
            lease_time_sec INTEGER,
            server_ip VARCHAR,
            interface_name VARCHAR,
            status VARCHAR
        );
        CREATE INDEX IF NOT EXISTS idx_dhcp_logs_time ON dhcp_logs(timestamp_us DESC);
        CREATE INDEX IF NOT EXISTS idx_dhcp_logs_mac ON dhcp_logs(client_mac);
        CREATE INDEX IF NOT EXISTS idx_dhcp_logs_ip ON dhcp_logs(assigned_ip);

        CREATE VIEW IF NOT EXISTS v_all_logs AS
        SELECT id, timestamp_us, level, logger_name, message, 'SYSTEM' AS category FROM system_logs
        UNION ALL
        SELECT id, timestamp_us, 'INFO' AS level, 'DnsService' AS logger_name, 
               concat(query_type, ' ', domain, ' -> ', rcode, ' (', latency_ms, 'ms)') AS message, 'DNS' AS category FROM dns_logs
        UNION ALL
        SELECT id, timestamp_us, 'INFO' AS level, concat('DhcpServer.', ip_version) AS logger_name,
               concat(message_type, ' ', client_mac, ' ', assigned_ip) AS message, 'DHCP' AS category FROM dhcp_logs;
        "
    ).map_err(|e| format!("Failed to create log schemas: {e}"))?;

    Ok(())
}

/// Append a single log entry into `app_logs` (legacy).
pub fn append_log(entry: DuckDbLogEntry) -> Result<(), String> {
    batch_append_logs(vec![entry])?;
    Ok(())
}

/// High-throughput batch appending using DuckDB Appender for `app_logs`.
pub fn batch_append_logs(entries: Vec<DuckDbLogEntry>) -> Result<usize, String> {
    if entries.is_empty() {
        return Ok(0);
    }

    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let count = entries.len();

    let mut appender = conn
        .appender("app_logs")
        .map_err(|e| format!("Failed to create appender: {e}"))?;

    for entry in entries {
        appender
            .append_row(params![
                entry.id,
                entry.timestamp_us,
                entry.level,
                entry.logger_name,
                entry.message,
                entry.query_type,
                entry.domain,
                entry.source_ip,
                entry.status,
                entry.latency_ms,
                entry.metadata,
            ])
            .map_err(|e| format!("Failed to append log row: {e}"))?;
    }

    appender
        .flush()
        .map_err(|e| format!("Failed to flush appender: {e}"))?;

    Ok(count)
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

/// Batch append entries to `dns_logs`.
pub fn batch_append_dns_logs(entries: Vec<DnsLogEntry>) -> Result<usize, String> {
    if entries.is_empty() {
        return Ok(0);
    }
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let count = entries.len();
    let mut appender = conn
        .appender("dns_logs")
        .map_err(|e| format!("Failed to create dns_logs appender: {e}"))?;

    for e in entries {
        appender
            .append_row(params![
                e.id,
                e.timestamp_us,
                e.client_ip,
                e.client_port,
                e.protocol,
                e.query_type,
                e.domain,
                e.rcode,
                e.answers,
                e.latency_ms,
                e.cached,
                e.upstream,
                e.status,
            ])
            .map_err(|e| format!("Failed to append dns_log row: {e}"))?;
    }
    appender
        .flush()
        .map_err(|e| format!("Failed to flush dns_logs appender: {e}"))?;
    Ok(count)
}

/// Batch append entries to `dhcp_logs`.
pub fn batch_append_dhcp_logs(entries: Vec<DhcpLogEntry>) -> Result<usize, String> {
    if entries.is_empty() {
        return Ok(0);
    }
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let count = entries.len();
    let mut appender = conn
        .appender("dhcp_logs")
        .map_err(|e| format!("Failed to create dhcp_logs appender: {e}"))?;

    for e in entries {
        appender
            .append_row(params![
                e.id,
                e.timestamp_us,
                e.ip_version,
                e.message_type,
                e.client_mac,
                e.hostname,
                e.assigned_ip,
                e.lease_time_sec,
                e.server_ip,
                e.interface_name,
                e.status,
            ])
            .map_err(|e| format!("Failed to append dhcp_log row: {e}"))?;
    }
    appender
        .flush()
        .map_err(|e| format!("Failed to flush dhcp_logs appender: {e}"))?;
    Ok(count)
}

/// Query recent logs with an optional limit and level filter (legacy).
pub fn query_recent_logs(
    limit: Option<u32>,
    level: Option<String>,
) -> Result<Vec<DuckDbLogEntry>, String> {
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;

    let lim = limit.unwrap_or(100);
    let (sql, filter_val) = match level {
        Some(lvl) if !lvl.is_empty() => (
            "SELECT id, timestamp_us, level, logger_name, message, query_type, domain, source_ip, status, latency_ms, metadata
             FROM app_logs
             WHERE level = ?
             ORDER BY timestamp_us DESC
             LIMIT ?;",
            Some(lvl),
        ),
        _ => (
            "SELECT id, timestamp_us, level, logger_name, message, query_type, domain, source_ip, status, latency_ms, metadata
             FROM app_logs
             ORDER BY timestamp_us DESC
             LIMIT ?;",
            None,
        ),
    };

    let mut stmt = conn.prepare(sql).map_err(|e| format!("Prepare error: {e}"))?;

    let row_mapper = |row: &duckdb::Row| -> duckdb::Result<DuckDbLogEntry> {
        Ok(DuckDbLogEntry {
            id: row.get(0)?,
            timestamp_us: row.get(1)?,
            level: row.get(2)?,
            logger_name: row.get(3)?,
            message: row.get(4)?,
            query_type: row.get(5)?,
            domain: row.get(6)?,
            source_ip: row.get(7)?,
            status: row.get(8)?,
            latency_ms: row.get(9)?,
            metadata: row.get(10)?,
        })
    };

    let entries: Vec<DuckDbLogEntry> = if let Some(lvl) = filter_val {
        let rows = stmt
            .query_map(params![lvl, lim], row_mapper)
            .map_err(|e| format!("Query error: {e}"))?;
        let mut list = Vec::new();
        for r in rows {
            list.push(r.map_err(|e| format!("Row parse error: {e}"))?);
        }
        list
    } else {
        let rows = stmt
            .query_map(params![lim], row_mapper)
            .map_err(|e| format!("Query error: {e}"))?;
        let mut list = Vec::new();
        for r in rows {
            list.push(r.map_err(|e| format!("Row parse error: {e}"))?);
        }
        list
    };

    Ok(entries)
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

/// Query DNS logs with optional domain, rcode filters and limit.
pub fn query_dns_logs(
    limit: Option<u32>,
    domain: Option<String>,
    rcode: Option<String>,
) -> Result<Vec<DnsLogEntry>, String> {
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let lim = limit.unwrap_or(100);

    let mut sql = "SELECT id, timestamp_us, client_ip, client_port, protocol, query_type, domain, rcode, answers, latency_ms, cached, upstream, status FROM dns_logs".to_string();
    let mut conditions = Vec::new();
    if domain.is_some() {
        conditions.push("domain = ?");
    }
    if rcode.is_some() {
        conditions.push("rcode = ?");
    }
    if !conditions.is_empty() {
        sql.push_str(" WHERE ");
        sql.push_str(&conditions.join(" AND "));
    }
    sql.push_str(" ORDER BY timestamp_us DESC LIMIT ?;");

    let mut stmt = conn.prepare(&sql).map_err(|e| format!("Prepare error: {e}"))?;
    let mapper = |row: &duckdb::Row| -> duckdb::Result<DnsLogEntry> {
        Ok(DnsLogEntry {
            id: row.get(0)?,
            timestamp_us: row.get(1)?,
            client_ip: row.get(2)?,
            client_port: row.get(3)?,
            protocol: row.get(4)?,
            query_type: row.get(5)?,
            domain: row.get(6)?,
            rcode: row.get(7)?,
            answers: row.get(8)?,
            latency_ms: row.get(9)?,
            cached: row.get(10)?,
            upstream: row.get(11)?,
            status: row.get(12)?,
        })
    };

    let rows: Vec<DnsLogEntry> = match (&domain, &rcode) {
        (Some(d), Some(r)) => {
            let r = stmt
                .query_map(params![d, r, lim], mapper)
                .map_err(|e| format!("Query error: {e}"))?;
            let mut list = Vec::new();
            for item in r {
                list.push(item.map_err(|e| format!("Row error: {e}"))?);
            }
            list
        }
        (Some(d), None) => {
            let r = stmt
                .query_map(params![d, lim], mapper)
                .map_err(|e| format!("Query error: {e}"))?;
            let mut list = Vec::new();
            for item in r {
                list.push(item.map_err(|e| format!("Row error: {e}"))?);
            }
            list
        }
        (None, Some(r)) => {
            let r = stmt
                .query_map(params![r, lim], mapper)
                .map_err(|e| format!("Query error: {e}"))?;
            let mut list = Vec::new();
            for item in r {
                list.push(item.map_err(|e| format!("Row error: {e}"))?);
            }
            list
        }
        (None, None) => {
            let r = stmt
                .query_map(params![lim], mapper)
                .map_err(|e| format!("Query error: {e}"))?;
            let mut list = Vec::new();
            for item in r {
                list.push(item.map_err(|e| format!("Row error: {e}"))?);
            }
            list
        }
    };

    Ok(rows)
}

/// Query DHCP logs with optional client_mac, assigned_ip filters and limit.
pub fn query_dhcp_logs(
    limit: Option<u32>,
    client_mac: Option<String>,
    assigned_ip: Option<String>,
) -> Result<Vec<DhcpLogEntry>, String> {
    let lock = DB_CONN.lock();
    let conn = lock.as_ref().ok_or_else(|| "Database not open".to_string())?;
    let lim = limit.unwrap_or(100);

    let mut sql = "SELECT id, timestamp_us, ip_version, message_type, client_mac, hostname, assigned_ip, lease_time_sec, server_ip, interface_name, status FROM dhcp_logs".to_string();
    let mut conditions = Vec::new();
    if client_mac.is_some() {
        conditions.push("client_mac = ?");
    }
    if assigned_ip.is_some() {
        conditions.push("assigned_ip = ?");
    }
    if !conditions.is_empty() {
        sql.push_str(" WHERE ");
        sql.push_str(&conditions.join(" AND "));
    }
    sql.push_str(" ORDER BY timestamp_us DESC LIMIT ?;");

    let mut stmt = conn.prepare(&sql).map_err(|e| format!("Prepare error: {e}"))?;
    let mapper = |row: &duckdb::Row| -> duckdb::Result<DhcpLogEntry> {
        Ok(DhcpLogEntry {
            id: row.get(0)?,
            timestamp_us: row.get(1)?,
            ip_version: row.get(2)?,
            message_type: row.get(3)?,
            client_mac: row.get(4)?,
            hostname: row.get(5)?,
            assigned_ip: row.get(6)?,
            lease_time_sec: row.get(7)?,
            server_ip: row.get(8)?,
            interface_name: row.get(9)?,
            status: row.get(10)?,
        })
    };

    let rows: Vec<DhcpLogEntry> = match (&client_mac, &assigned_ip) {
        (Some(m), Some(ip)) => {
            let r = stmt
                .query_map(params![m, ip, lim], mapper)
                .map_err(|e| format!("Query error: {e}"))?;
            let mut list = Vec::new();
            for item in r {
                list.push(item.map_err(|e| format!("Row error: {e}"))?);
            }
            list
        }
        (Some(m), None) => {
            let r = stmt
                .query_map(params![m, lim], mapper)
                .map_err(|e| format!("Query error: {e}"))?;
            let mut list = Vec::new();
            for item in r {
                list.push(item.map_err(|e| format!("Row error: {e}"))?);
            }
            list
        }
        (None, Some(ip)) => {
            let r = stmt
                .query_map(params![ip, lim], mapper)
                .map_err(|e| format!("Query error: {e}"))?;
            let mut list = Vec::new();
            for item in r {
                list.push(item.map_err(|e| format!("Row error: {e}"))?);
            }
            list
        }
        (None, None) => {
            let r = stmt
                .query_map(params![lim], mapper)
                .map_err(|e| format!("Query error: {e}"))?;
            let mut list = Vec::new();
            for item in r {
                list.push(item.map_err(|e| format!("Row error: {e}"))?);
            }
            list
        }
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
