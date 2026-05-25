# Phase 1 — Discovery Outputs

Files written here by `discovery-agent`:

| File | When |
|------|------|
| `company-brief.md` | After Task 1 (Gate 1A) — company research, industry context, Confluent use case fit |
| `stakeholder-map.md` | After Task 2 (internal, not shared with customer) — stakeholder psychology, hidden concerns, veto axes |
| `questions.md` | After Task 3 (Gate 1B) — Confluent-specific discovery questions by stakeholder |
| `meeting-summary.md` | After Task 5 (Gate 1C) — structured meeting notes |
| `requirements.md` | After Task 5 — functional and non-functional requirements |
| `gap-analysis.md` | After Task 5 — blockers and important gaps |
| `follow-up.md` | After Task 5 — follow-up email + action items |

## Confluent-Specific Discovery Focus Areas

The discovery agent focuses on these Confluent-relevant areas:

1. **Current messaging/streaming stack** — self-managed Kafka, MSK, Pulsar, RabbitMQ, or nothing
2. **Pain points with current stack** — operational overhead, scaling, connector ecosystem, schema management
3. **Use case fit** — CDC, real-time analytics, event-driven microservices, streaming ETL, AI/ML pipelines
4. **Throughput and scale** — messages/sec, MB/sec, number of topics, retention requirements
5. **Stream processing needs** — Flink, ksqlDB, or application-side processing
6. **Schema management** — Avro, Protobuf, JSON Schema, or no schema management today
7. **Connector requirements** — source systems (databases, SaaS, IoT) and sink systems (data warehouse, search, cache)
8. **Compliance and data residency** — GDPR, PCI DSS, HIPAA, data sovereignty requirements
9. **Build vs. buy philosophy** — appetite for managed services vs. self-managed Kafka
10. **Competitive context** — evaluating MSK, Redpanda, Pulsar, or staying on self-managed Kafka
