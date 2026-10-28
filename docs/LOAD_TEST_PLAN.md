# One More Rep — Load Test Plan (Reproducible)

**Status:** Draft — do **not** claim 100,000 users until load testing demonstrates capacity. Targets are initial and must be adjusted after baselines.

## Objectives
- Establish baselines for latency, throughput, error rate.
- Validate pagination limits, rate limiting, tenant isolation under load.
- Identify N+1, connection exhaustion, queue backpressure.
- Test idempotency and transaction contention.

## Tools
- [k6](https://k6.io/) (recommended) — scriptable, CI-friendly, good metrics.
- Locust or Artillery as alternatives.

## Test Scenarios (Realistic)

| Scenario | Description | Weight (suggested) | Notes |
|----------|-------------|-------------------|-------|
| `health` | GET `/api/v1/health` | 10% | Baseline, cache-friendly if added later |
| `auth_login` | POST `/api/v1/auth/login` with valid test user | 15% | Watch rate limits (throttle:auth), DB connections |
| `auth_me` | GET `/api/v1/auth/me` with token | 20% | Authenticated read |
| `coach_trainees_list` | GET `/api/v1/coach/trainees` paginated | 25% | Must enforce pagination + tenant isolation |
| `admin_users_list` | GET `/api/v1/admin/users` paginated | 15% | Super admin scope, must be isolated/authorized |
| `writes` | Small authenticated writes (if/when added) | 15% | Use transactions/locks, watch contention |

## Initial Targets
| Metric | Target | Action if breached |
|--------|--------|-------------------|
| p50 latency | < 150ms | Investigate |
| p95 latency | < 300ms | Investigate |
| p99 latency | < 800ms | Investigate |
| Error rate (5xx) | < 0.1% | Block release |
| Error rate (4xx unexpected) | < 1% | Investigate (rate limits expected) |
| Throughput | Meet baseline — target | Scale only with justification |

**Critical:** No target claims 100k concurrent users. Run stair-step tests to find breaking point.

## Environment Setup
1. Use a staging-like environment with production-like DB config (separate from prod).
2. Seed realistic test data (users/roles/relationships) — never use real PII.
3. Configure rate limits appropriately for test runs or use dedicated test keys.
4. Monitor DB: connections, `pg_stat_statements`, locks, slow queries.
5. Monitor app: queue depth, failed jobs, cache hit rate, logs.

## k6 Example Script (Template)
Create `tests/load/k6-smoke.js` (do not commit secrets):

```js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 10 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<300'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export default function () {
  const res = http.get(`${BASE_URL}/api/v1/health`);
  check(res, { 'health ok': (r) => r.status === 200 });
  sleep(1);
}
```

## Execution
```bash
k6 run tests/load/k6-smoke.js --env BASE_URL=https://staging.example.com
```

## Reporting
Record: environment, commit SHA, DB size, instance count, results (p50/p95/p99, RPS, errors), bottlenecks, and follow-ups. Update this plan with findings.

## Notes
- Do **not** run destructive DB operations.
- Respect rate limits.
- Never load real user data.
- Adding Redis/PgBouncer/Octane/replicas requires explicit justification + compatibility validation.
