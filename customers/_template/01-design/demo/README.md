# Confluent Cloud Demo Environment

This directory contains a complete, use-case-specific demo environment that can be spun up with one command.

## Demo Components

| File/Directory | Purpose |
|---------------|---------|
| `setup.sh` | One-command demo environment setup (Terraform + data generator) |
| `teardown.sh` | One-command cleanup |
| `data-generator/` | Python data generator with Schema Registry integration |
| `consumers/` | Sample consumer applications |
| `flink-queries.sql` | Flink SQL statements for stream processing |
| `ksql-queries.sql` | ksqlDB queries (alternative to Flink) |
| `dashboards/` | Grafana/Kibana dashboard configs |
| `talking-points.md` | What to say at each demo step, mapped to customer pain points |
| `troubleshooting.md` | What to do if something goes wrong |

## Quick Start

### 1. Prerequisites
- Confluent Cloud account with Cloud API Key
- AWS account (for S3 bucket, if using S3 Sink connector)
- Python 3.8+ with pip
- Terraform >= 1.6.0
- jq (for parsing JSON outputs)

### 2. Setup
```bash
# Set Confluent Cloud credentials
export TF_VAR_confluent_cloud_api_key="<your-cloud-api-key>"
export TF_VAR_confluent_cloud_api_secret="<your-cloud-api-secret>"

# Run setup (provisions Confluent Cloud + starts data generator)
./setup.sh
```

### 3. View Demo
- Open Confluent Cloud UI: https://confluent.cloud
- Navigate to your environment → cluster → Topics
- Watch events flowing in real-time

### 4. Teardown
```bash
./teardown.sh
```

## Demo Timeline

| Time | Activity | What to Show |
|------|----------|--------------|
| 0-2 min | Intro | Customer's problem statement, proposed architecture |
| 2-5 min | Source data | Existing database/application, current pain points |
| 5-10 min | Confluent Cloud setup | Connectors, topics, Schema Registry |
| 10-15 min | Stream processing | Flink/ksqlDB transformations in real-time |
| 15-20 min | Sinks & visualization | Data flowing to downstream systems, dashboards |
| 20-25 min | Wrap-up & Q&A | Next steps, POC plan, cost estimate |

## Customization

Edit `data-generator/producer.py` to match customer's:
- Industry (financial services, media, IoT, retail, etc.)
- Event types (transactions, user activity, sensor readings, etc.)
- Data volume (messages/sec)
- Schema (Avro/Protobuf fields)

## Cost Warning

⚠️ **This demo provisions real Confluent Cloud resources that incur costs.**

Estimated cost:
- **Standard cluster:** ~$0.91/CKU/hour (pay for what you use)
- **Dedicated cluster (1 CKU):** ~$1.50/hour
- **Connectors:** ~$0.25/task/hour
- **Flink (if used):** ~$0.52/CFU/hour

**Always run `teardown.sh` after the demo to avoid ongoing charges.**

For a free demo environment, use Confluent Cloud free trial (300 free usage credits).

## Troubleshooting

See `troubleshooting.md` for common issues and fixes.
