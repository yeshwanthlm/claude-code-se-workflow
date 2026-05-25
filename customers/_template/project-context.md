# Project Context: [Company Name]

> This is the living document for this engagement. It is read by every agent and updated at every gate.
> Do not delete sections — add to them. Accumulated context is what makes later phases sharper.

---

## Engagement Basics

| Field | Value |
|-------|-------|
| Company | |
| Industry | |
| Meeting Date | |
| Meeting Duration | |
| Meeting Format | (in-person / video) |
| Internal Account Owner | (AE / CSM / SDR name) |
| Engagement Start | |
| Target Use Case | (CDC / real-time analytics / event-driven microservices / streaming ETL / AI-ML / IoT / fraud detection) |
| Confluent Products in Scope | (Kafka / Schema Registry / Flink / ksqlDB / Connectors / Stream Governance / Tableflow) |

---

## Stakeholders

<!-- Add one block per person in the room -->

### [Name] — [Role]
- **Top concern / mandate:**
- **What keeps them up at night:**
- **Decision-making style:** (data-driven / gut / consensus / cost-first)
- **Known risk factors:** (e.g. risk-averse, cost pressure, political dynamics)
- **Relationship history:** (new contact / established trust / skeptic)
- **Confluent familiarity:** (none / heard of Kafka / used Kafka / used Confluent Cloud)

### [Name] — [Role]
- **Top concern / mandate:**
- **What keeps them up at night:**
- **Decision-making style:**
- **Known risk factors:**
- **Relationship history:**
- **Confluent familiarity:**

---

## Known Constraints

### Technical
- Existing messaging/streaming stack: (self-managed Kafka / MSK / Pulsar / RabbitMQ / none)
- Existing cloud provider: (AWS / GCP / Azure / multi-cloud / on-prem)
- Team skills / gaps:
- Preferred technologies:
- Technologies to avoid:
- Pain points with current stack:

### Business
- Budget range / pressure:
- Timeline / deadline:
- Risk tolerance: (conservative / moderate / aggressive)
- Compliance requirements: (GDPR / PCI DSS / HIPAA / SOC 2 / ISO 27001)
- Build vs. buy philosophy:

### Organisational
- Team size:
- Change management capacity:
- Previous failed projects (and why):
- Existing Confluent relationship: (new logo / existing customer / expansion)

---

## Target Use Case

<!-- Describe the primary use case in 2-3 sentences -->

**Primary use case:**

**Use case category:** (CDC / real-time analytics / event-driven microservices / streaming ETL / AI-ML feature engineering / IoT / multi-region replication)

**Data sources:**

**Data consumers / sinks:**

**Estimated throughput:** (messages/sec, MB/sec)

**Latency requirements:** (real-time <100ms / near-real-time <1s / batch-like <1min)

**Retention requirements:**

---

## Confluent Cloud Requirements

### Cluster Configuration
- **Preferred cluster type:** (Basic / Standard / Dedicated / Enterprise / Unknown)
- **Cloud provider:** (AWS / GCP / Azure / Multi-cloud / Unknown)
- **Region(s):** (us-east-1, eu-west-1, etc.)
- **Multi-region requirements:** (single region / active-passive DR / active-active / Unknown)
- **Private networking:** (Public internet / AWS PrivateLink / VPC Peering / Unknown)

### Schema Management
- **Current schema approach:** (No schemas / JSON Schema / Avro / Protobuf / Unknown)
- **Schema Registry requirement:** (Required / Nice-to-have / Not needed)
- **Schema evolution needs:** (Frequent schema changes / Stable schemas / Unknown)

### Connectors Needed
| Connector Type | Source/Sink | Technology | Priority | Notes |
|---------------|------------|------------|----------|-------|
| (e.g., Debezium PostgreSQL CDC) | Source | PostgreSQL | High | Production database, 10 tables |
| (e.g., S3 Sink) | Sink | AWS S3 | High | Event archive, 7-day retention |
| | | | | |

### Stream Processing
- **Processing requirements:** (Filtering / Enrichment / Aggregation / Joins / Sessionization / Pattern matching / Unknown)
- **Preferred engine:** (Flink / ksqlDB / Application-side (Kafka Streams, Python, Java) / Unknown)
- **Stateful processing needed:** (Yes — describe / No / Unknown)
- **Real-time vs. batch tolerance:** (<1s / <5s / <1min / batch is acceptable)

### Stream Governance
- **Governance requirements:** (Data lineage / Business metadata / PII detection / Data quality rules / None / Unknown)
- **Compliance drivers:** (GDPR / PCI DSS / HIPAA / SOC 2 / ISO 27001 / None)
- **Stream Governance tier:** (Essentials / Advanced / Unknown)

### Tableflow (Kafka → Iceberg)
- **Data lakehouse requirements:** (Kafka topics → Iceberg tables / Not needed / Unknown)
- **Query engines:** (Athena / Trino / Presto / Databricks / Snowflake / Unknown)
- **Use case:** (Real-time analytics on streaming data / Long-term archival / BI tools / Unknown)

---

## Competitive Landscape

**Alternatives being evaluated:**
- [ ] AWS MSK (Managed Kafka on AWS)
- [ ] Redpanda Cloud
- [ ] Pulsar
- [ ] Self-managed Kafka (open-source on K8s/EC2)
- [ ] Message queues (RabbitMQ, SQS, Azure Service Bus)
- [ ] None — Confluent Cloud is the only option being considered

**Why evaluating alternatives:**
- Cost concerns
- Existing cloud commitment (AWS, GCP, Azure)
- Control / customization requirements
- Team preference / expertise
- Unknown

**What would make Confluent Cloud the obvious choice:**
-

**What would be a deal-breaker for Confluent Cloud:**
-

**Competitive win factors:**
| Factor | Confluent Cloud Advantage | Proof Point Needed |
|--------|--------------------------|-------------------|
| Managed Flink | ✅ Fully managed (vs. EMR for MSK, self-managed for others) | Demo Flink SQL in action |
| Managed Connectors | ✅ 120+ connectors, zero infrastructure | Show Debezium CDC + S3 Sink setup time |
| Schema Registry | ✅ Advanced features (vs. Glue Schema Registry for MSK) | Show schema evolution, compatibility checks |
| Stream Governance | ✅ Data lineage, PII detection (no equivalent in MSK/Redpanda) | Show data lineage for compliance |
| Multi-cloud | ✅ AWS, GCP, Azure (vs. AWS-only for MSK) | Discuss future multi-cloud strategy |
| TCO | ⚠️ Must prove (vs. MSK compute-only pricing) | 3-year TCO comparison (incl. ops team) |

---

## What We Don't Know Yet

<!-- Explicit gaps before research starts — updated at every gate -->
<!-- Legend: [x] = resolved, [~] = partially resolved, [ ] = still open -->

### Technical Gaps
- [ ] Current messaging/streaming stack details
- [ ] Peak throughput and message size
- [ ] Number of topics / partitions needed
- [ ] Connector requirements (sources and sinks)
- [ ] Stream processing requirements (Flink vs. ksqlDB vs. application-side)
- [ ] Schema management approach today
- [ ] Data residency / compliance requirements

### Business Gaps
- [ ] Budget envelope for Confluent Cloud
- [ ] Timeline for POC / production
- [ ] Decision-making process (who approves, when)
- [ ] Funding source (existing budget line item / new budget request)

### Competitive Intelligence Gaps
- [ ] Which alternatives are actively being evaluated (not just considered)
- [ ] What is the primary driver for evaluating alternatives (cost / control / familiarity)
- [ ] Has a competitor already presented? If so, what did they propose?
- [ ] What objections or concerns have been raised about Confluent Cloud?

---

## Internal Partner Intelligence

> What the AE / CSM / SDR knows that won't appear in a web search

-
-
-

---

## Meeting Log

<!-- Added after each meeting by the discovery agent -->

### Meeting 1 — [Date]
**Learnings:**
**Decisions made:**
**What changed from what we assumed:**

---

## Architecture Decisions

<!-- Populated during Phase 2 -->

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Confluent cluster type | | |
| Cloud provider / region | | |
| Stream processing engine | | |
| Schema format | | |
| Connector strategy | | |
| Private networking | | |

---

## Demo Plan

<!-- Populated during Phase 2 -->

| Demo Component | Description | Status |
|---------------|-------------|--------|
| Use case scenario | | |
| Data generator | | |
| Topics / schemas | | |
| Stream processing | | |
| Sink / visualization | | |

---

## Open Questions (Carry-Forward)

<!-- Updated at every gate — resolved questions get checked off -->

- [ ]
- [ ]
