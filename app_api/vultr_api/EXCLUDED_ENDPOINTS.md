# Excluded Vultr API Endpoints

This document describes the endpoints and schemas that were excluded from the generated API client to avoid compilation errors.

## Summary

- **Original:** 34 API clients, 476+ models, 270 compilation errors
- **After exclusions:** 32 API clients, 348 models, 0 errors
- **Removed:** 7,610 lines from OpenAPI spec

## Excluded API Sections

### 1. Managed Databases API
**Endpoints removed:** All `/databases/*` paths (lines 16634-21072 in original spec)

**Reason:** The PostgreSQL advanced options schemas contained complex enum values with escaped strings that caused parser errors:
```dart
// This caused 248 compilation errors:
static const quotePidEqualPercentPComma... =
  PgAdvancedOptionsLogLinePrefixEnum._(r'\'pid=%p,user=%u,db=%d,app=%a,client=%h \'');
```

**Schemas removed:**
- `database`
- `database-usage`
- `database-user`
- `database-topic`
- `database-quota`
- `database-connector*` (multiple)
- `database-db`
- `pg-advanced-options`
- `mysql-advanced-options`
- `kafka-advanced-options`
- `kafka-rest-advanced-options`
- `schema-registry-advanced-options`
- `kafka-connect-advanced-options`
- `kafka-permissions`

**Impact:** Cannot manage Vultr Managed Databases (PostgreSQL, MySQL, Redis, Kafka) through this API client.

### 2. Container Registry API
**Endpoints removed:**
- All `/registry/*` paths (lines 21450-22770 in original spec)
- `/registries` path (list all registries)

**Reason:** The OpenAPI spec had a malformed parameter definition (`vcr_region` missing the `in` field), causing the code generator to create `UNKNOWN_PARAMETER_NAME` placeholders that resulted in 12 compilation errors.

**Schemas removed:**
- `registry`
- `replication`
- `retention-rule`
- `registry-storage`
- `registry-repository`
- `registry-user`
- `registry-user-current`
- `registry-region`
- `registry-plan`
- `registry-docker-credentials`
- `registry-kubernetes-docker-credentials`
- `registry-repository-artifact`
- `registry-robot`

**Impact:** Cannot manage Vultr Container Registry subscriptions through this API client.

## Manual Code Fixes

### listFromJson Errors (6 fixes)
The OpenAPI spec defined arrays with untyped objects (`items: type: object` without schema reference), causing the generator to create invalid code like `Object.listFromJson()`.

**Files patched:**
1. `lib/model/create_instance_request.dart` (1 fix)
2. `lib/model/get_bare_metals_upgrades200_response_upgrades.dart` (2 fixes)
3. `lib/model/get_instance_upgrades200_response_upgrades.dart` (3 fixes)

**Fix applied:**
```dart
// Before:
blockDevices: Object.listFromJson(json[r'block_devices'])

// After:
blockDevices: json[r'block_devices'] is Iterable
    ? (json[r'block_devices'] as Iterable).cast<Object>().toList(growable: false)
    : const []
```

## Available API Endpoints

The generated client still includes 32 fully functional API clients for:
- Account Management
- API Keys
- Applications
- Backups
- Bare Metal Servers
- Billing
- Block Storage
- CDNs
- DNS
- Firewalls
- Instances (VPS)
- ISO
- Kubernetes
- Load Balancers
- Logs
- Marketplace
- Operating Systems
- Plans
- Private Networks
- Regions
- Reserved IPs
- S3 Object Storage
- Serverless Inference
- Snapshots
- SSH Keys
- Startup Scripts
- Storage Gateways
- Subaccounts
- Users
- VFS (Virtual File System)
- VPC 2.0
- VPCs (legacy)

## Regeneration Notes

If you need to regenerate the code:

1. Use the modified `openapi.yaml` (database and registry sections already removed)
2. Run: `openapi-generator generate -i openapi.yaml -g dart -o . --skip-validate-spec`
3. Apply the listFromJson patches manually (see above)

## Original Spec

The original unmodified OpenAPI spec is preserved in `openapi.yaml.backup` for reference.
