# One More Rep — Scalability Review (Production Readiness)

This review is based on the current codebase state as committed. It covers database, queries, caching, queues, tenancy/isolation, statelessness, operations, testing/load, and concrete recommendations. Do **not** treat this as claiming 100k users — capacity must be proven by load tests (see Load Test Plan).

## Current State Summary

- **Stack**: Flutter mobile, Laravel API, PostgreSQL (pgsql), Sanctum auth, database-backed cache/queue by default.
- **Tenancy/roles**: `super_admin`, `coach`, `trainee`. Relationships modeled via `coach_trainee_relationships` with active pair/primary constraints. Tenant isolation is partially enforced via middleware (`role`) and model helpers.
- **Auth**: Sanctum tokens, active/verified/role middlewares, rate limiting configured in routes. Email verification enforced for coach/admin routes.
- **Migrations present**: users/roles/user_roles, profiles, relationships, audit logs, tokens, cache/jobs.

## 1) PostgreSQL Indexes, Foreign Keys, Constraints

### What exists
- Foreign keys with cascadeOnDelete/nullOnDelete where appropriate.
- Composite/targeted indexes on relationships and lookup tables.
- Partial unique indexes for active relationships (Postgres). Migration has SQLite fallbacks noted.
- Email normalization logic present; functional unique index attempt exists in migration flow.

### Gaps / Recommendations
| Issue | Risk | Recommendation | Status |
|------|------|---------------|--------|
| No permanent functional unique index on `LOWER(users.email)` in final schema | Race condition on registration under concurrency | Add a permanent Postgres migration creating `UNIQUE INDEX CONCURRENTLY users_email_lower_key ON users (LOWER(email))`. CONCURRENTLY cannot run inside a transaction block — use non-transactional migration or separate approach. | TODO |
| Missing indexes for common admin/coach filters | Slow queries as data grows | Add indexes based on EXPLAIN (ANALYZE, BUFFERS) from real query plans. Avoid over-indexing. | TODO |
| audit_logs retention/partitioning | Table growth | Define retention policy now; partitioning only if justified by volume and measured need. | Monitor |

## 2) Queries, N+1, SELECT *, Unbounded Collections, Pagination

### Gaps / Recommendations
| Issue | Risk | Recommendation | Status |
|------|------|---------------|--------|
| N+1 queries | Latency multiplies under load | Eager load explicitly (`with`, `loadMissing`). Consider `Model::preventLazyLoading()` in local/testing. | TODO |
| Unbounded queries | Memory/timeout risk | Ban unbounded loads. Use pagination (`paginate`/`simplePaginate`/cursor). Enforce max page size server-side (e.g., 100). | TODO |
| SELECT * | Excess I/O, schema coupling | Select only needed columns; use API Resources. | TODO |
| Tenant scoping | Data leak (critical) | Global scopes/policies/traits for tenant isolation. Never trust client-supplied tenant IDs. Every query must be scoped to authorized context. | TODO |

## 3) Transactions, Connection Usage, Pooling

| Area | Recommendation | Status |
|------|---------------|--------|
| Transactions | Wrap multi-step writes in `DB::transaction()`; use `lockForUpdate()` for counters/slots. | TODO |
| Connection usage | Keep stateless, avoid long transactions holding connections. | TODO |
| Connection pooling | Do NOT add PgBouncer blindly. Measure first (active conns, timeouts). If needed, document transaction vs session pooling, prepared statements, LISTEN/NOTIFY compatibility. | HOLD - measure first |
| Timeouts | Configure PDO/connect/statement timeouts; consider DB-level statement_timeout. | TODO |

## 4) Caching Strategy (Careful)

| Rule | Recommendation | Status |
|------|---------------|--------|
| Never cache authz/payment decisions | Authorization and payment/voucher validity must hit source of truth with proper locking. | CRITICAL |
| Explicit invalidation | Use tags/events/observers with documented invalidation paths. | TODO |
| Tenant-aware keys | Include tenant/user/coach context in keys. | CRITICAL |
| TTLs | Short TTLs for semi-dynamic data; avoid caching volatile lists without invalidation. | TODO |
| Redis | Do NOT add blindly; measure first and justify. | HOLD - measure first |

## 5) Queues, Jobs, Idempotency

| Area | Recommendation | Status |
|------|---------------|--------|
| Move slow work | Emails, notifications, reports, AI, webhooks -> queues. | TODO |
| Idempotency | Idempotent jobs (unique keys/idempotency keys), check state before acting, safe retries. | CRITICAL |
| Failed jobs | Monitor `failed_jobs`, use `tries()`, `backoff()`, alerting/DLQ. | TODO |
| Concurrency safety | Use locks when jobs touch shared state. | TODO |

## 6) Statelessness, Shared State

| Area | Recommendation | Status |
|------|---------------|--------|
| Stateless API | No in-process cross-request state; use DB/cache. Sanctum tokens are stateless. | OK with care |
| Files/uploads | If scaled horizontally, use S3-compatible storage. | TODO when needed |
| Sessions/broadcasting | If added later, need shared session store/broadcaster. | Monitor |

## 7) Operations: Pooling, Backups, Monitoring, Horizontal Scaling

| Area | Recommendation | Status |
|------|---------------|--------|
| Connection pooling | Document PgBouncer options and compatibility checklist. | DOC TODO |
| Backups/recovery | WAL archiving, logical backups, PITR, restore testing, RPO/RTO, encryption/offsite. | DOC TODO |
| Monitoring | pg_stat_statements, connections, slow queries, p50/p95/p99, 5xx/429, queue depth/failed jobs, cache hit rate, endpoint latency. | DOC TODO |
| Horizontal scaling | Multiple stateless API instances behind LB OK. Shared DB/cache/queue. Read replicas only with read/write splitting and lag-aware handling. No blind additions. | DOC TODO |

## 8) Testing & Load Testing

- Add tests: pagination, tenant isolation, authorization, idempotency, transaction/race cases.
- Create reproducible load test plan with realistic scenarios and measurable targets.
- **Do not claim 100k users until load testing demonstrates capacity.**

### Initial Targets (adjust after baselines)
| Scenario | Target (initial) | Notes |
|----------|-------------------|-------|
| Health/read-heavy | p95 < 200ms, p99 < 500ms, error < 0.1% | Measure with/without cache |
| Auth | p95 < 300ms, error < 0.1% | Rate-limited |
| Paginated lists | p95 < 250ms, error < 0.1% | Enforce max page size |
| Writes (tx/locks) | p95 < 400ms, error < 0.1% | Watch contention |
| Queue jobs | Within SLA, idempotent, DLQ monitored | Not request latency |

## Immediate Actions (this pass)
1. Document review (this file).
2. Establish pagination defaults, max page size, tenant isolation patterns.
3. Add migration for case-insensitive email unique index on Postgres (CONCURRENTLY) with transaction-safety notes.
4. Add safeguards/docs against caching authz/payments.
5. Document job idempotency patterns.
6. Add scaffolding tests for pagination/tenant isolation.
7. Create load test plan with k6 examples.

**Rule**: No Redis/PgBouncer/Octane/replicas/partitioning added blindly. Justify and validate compatibility first.
