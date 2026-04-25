![CI](https://github.com/Demontrick/payment-ops-api/actions/workflows/ci.yml/badge.svg)

# payment-ops-api

> GoCardless processes $130bn+ in payments annually. 
> When a payment fails at 2am, nobody should be paged to retry it manually.

A Rails + Sidekiq + PostgreSQL service that automates payment operations 
— fraud detection, intelligent retry logic, and risk scoring running 
in the background without human intervention.

Built to reflect the exact work of GoCardless's Service Management team: 
move beyond manual payment ops tasks by building automated systems that 
handle the heavy lifting.

---

## The Problem

Payment failures happen constantly at scale. Manual retry processes 
don't scale. Fraud detection that requires human review for every 
transaction doesn't scale. Operations teams get paged at 2am for 
things a system should handle automatically.

## The Solution

Three parallel Sidekiq workers handle the entire payment operations 
lifecycle automatically — fraud scoring on creation, intelligent retry 
on failure, risk summary generation for audit trail. Every worker is 
idempotent. No duplicate processing. No manual intervention.

---

## Stack

- Ruby on Rails 7 — API mode
- Sidekiq + sidekiq-throttled — concurrent background processing
- Redis — queue management + idempotency locks
- PostgreSQL — payment state + operation audit log
- RSpec — worker and service tests
- GitHub Actions CI — PostgreSQL + Redis service containers

---

## How It Works
POST /api/v1/payments

Payment created → three workers fire automatically:

| Worker | Queue | What it does |
|--------|-------|--------------|
| FraudDetectionWorker | default | Scores risk 0-100, flags if above 75 |
| PaymentRetryWorker | critical | Retries failed payments, max 3 attempts |
| RiskSummaryWorker | bulk | Generates audit trail entry per payment |

Every action logged to OperationLog — full audit trail, no silent failures.

---

## Endpoints
POST /api/v1/payments              # Create payment, triggers workers
GET  /api/v1/payments/:id          # Get payment status + risk score
POST /api/v1/payments/:id/retry    # Manual retry trigger
GET  /api/v1/operations            # Full operation audit log

---

## Payment State Machine
pending → completed
pending → flagged (risk score > 75)
pending → failed (after 3 retry attempts)
failed  → pending (on retry)

---

## Key Engineering Decisions

**Idempotent workers via Redis locks** — a payment cannot be processed 
twice by the same worker type. Solves duplicate job execution at scale 
without complex deduplication logic.

**sidekiq-throttled concurrency caps** — prevents worker fleet from 
overloading PostgreSQL under high payment volume. Same principle 
GoCardless uses internally for job queue management.

**Priority queues** — retry logic runs on critical queue first. 
Risk summaries run on bulk queue last. Load stays predictable 
under payment spikes.

**Exponential backoff** — retry intervals increase with each attempt. 
Max 3 retries before payment marked failed. No infinite retry loops.

**OperationLog audit trail** — every worker action recorded with 
payment_id, action, result, worker_type, timestamp. Full observability 
without external tooling.

---

## Running Tests

```bash
bundle exec rspec
```

Tests cover fraud detection logic, retry limit enforcement, 
state transitions, and worker idempotency.

---

## CI

GitHub Actions runs full RSpec suite on every push with 
PostgreSQL 15 and Redis 7 service containers — Ruby 3.2, 
no local setup needed.
