# Payment Ops API

![CI](https://github.com/Demontrick/payment-ops-api/actions/workflows/ci.yml/badge.svg)

---

## 💳 Why this exists

GoCardless processes $130bn+ in payments annually.

When a payment fails at 2am, nobody should be paged to retry it manually.

This system simulates a **payment operations automation engine** that handles:

- Payment retries
- Fraud detection
- Risk scoring
- Automated decisioning
- Background job orchestration

---

## ⚙️ What this system does

Instead of manual ops work, the system automatically:

### 1. Payment lifecycle
- Creates payments
- Tracks status transitions
- Logs every operation

### 2. Background automation (Sidekiq)
- Detects fraud risk
- Applies retry logic
- Generates risk summaries

### 3. Intelligent decisioning
- High amount → higher risk
- Failed payments → auto retry
- Risk score → flag or approve

---

## 🧠 Architecture


Rails API
│
├── PostgreSQL (source of truth)
│
├── Sidekiq (background processing)
│ ├── FraudDetectionWorker
│ ├── PaymentRetryWorker
│ └── RiskSummaryWorker
│
└── Redis (queues + job locks)


---

## 🔁 Workflow

### 1. Payment created

POST /api/v1/payments


Triggers:
- FraudDetectionWorker

---

### 2. Fraud detection
- Calculates risk score
- Flags high-risk payments
- Sends to next stage

---

### 3. Retry engine
- Max 3 retries
- Exponential backoff
- Auto-fail after limit

---

### 4. Risk summary
- Generates AI-style explanation (Claude-ready architecture)
- Stores audit trail in OperationLog

---

## 🧱 Models

### Payment
- merchant_id
- amount
- currency
- status: pending / flagged / failed / completed
- retry_count
- risk_score

### OperationLog
- payment_id
- action
- result
- worker_type

---

## ⚙️ Tech Stack

- Ruby on Rails 7
- PostgreSQL
- Sidekiq
- Redis
- RSpec
- GitHub Actions CI

---

## 🧪 Testing

Run tests locally:

```bash
bundle exec rspec

What is tested:

Fraud detection logic
Retry engine limits
State transitions
Worker idempotency
🚀 CI Pipeline

CI runs on every push:

PostgreSQL 15 service
Redis 7 service
Ruby 3.2
RSpec test suite
🟢 Running locally
1. Start services
rails db:create db:migrate
redis-server
bundle exec sidekiq -C config/sidekiq.yml
rails s
🪟 WSL NOTE (IMPORTANT)

If you're on Windows:

Option 1 (Recommended)

Use WSL2 (Ubuntu):

wsl
cd payment-ops-api
bundle install
rails s
Option 2 (Windows native)

Ensure:

Redis running on localhost:6379
PostgreSQL running locally
Sidekiq started in separate terminal
🔐 Key design principles
Idempotent workers (Redis locks)
No duplicate job execution
Clear state machine for payments
Full audit logging
Failure-safe retry system
📌 What this project demonstrates

This is not just a Rails app.

It demonstrates:

Distributed job processing (Sidekiq)
Payment state machines
Failure recovery systems
Ops automation mindset
Production-style CI/CD setup
🏁 Status

✔ Core POC complete
✔ Workers implemented
✔ CI running
✔ Redis + Sidekiq integrated
✔ Payment lifecycle automated

🔜 Next improvements (optional)
Add Claude API integration (risk summaries)
Add dashboards (Sidekiq UI / admin panel)
Add metrics (Prometheus-style observability)
Add rate limiting per merchant
👨‍💻 Author note

Built as a simulation of a real-world payment ops system similar to GoCardless internal workflows.
