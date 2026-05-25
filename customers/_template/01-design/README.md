# Phase 2 — Design Outputs

Files written here by `design-agent`, `diagram-agent`, `iac-agent`, `documentation-agent`, `demo-agent`:

| File | Agent | When |
|------|-------|------|
| `architecture-options.md` | design-agent | Gate 2A |
| `reference-architectures.md` | design-agent | Gate 2A |
| `<company>-architecture.png` | diagram-agent | After Gate 2A |
| `ADR-001-*.md` through `ADR-007-*.md` | documentation-agent | After Gate 2A |
| `confluent-terraform/` | iac-agent | After Gate 2A |
| `aws-terraform/` | iac-agent | After Gate 2A |
| `demo/` | demo-agent | After Gate 2A |
| `architecture-summary.md` | documentation-agent | Gate 2B |

## Confluent Cloud Terraform Structure

```
confluent-terraform/
  main.tf              Provider config, Confluent Cloud credentials
  variables.tf         Input variables (environment name, cluster type, region, etc.)
  outputs.tf           Bootstrap servers, Schema Registry URL, API keys
  locals.tf            Derived values, naming conventions
  environment.tf       confluent_environment
  cluster.tf           confluent_kafka_cluster (Basic / Standard / Dedicated)
  schema-registry.tf   confluent_schema_registry_cluster
  topics.tf            confluent_kafka_topic (all topics)
  connectors.tf        confluent_connector (source and sink connectors)
  flink.tf             confluent_flink_compute_pool, confluent_flink_statement
  iam.tf               confluent_service_account, confluent_role_binding, confluent_api_key
  stream-governance.tf confluent_tag, confluent_business_metadata, confluent_subject_config
  README.md
  GETTING_STARTED.md
  terraform.tfvars.example
```

## AWS Terraform Structure

```
aws-terraform/
  main.tf              Provider config, S3 backend
  variables.tf         Input variables
  outputs.tf           Key resource outputs
  locals.tf            Derived values
  vpc.tf               VPC, subnets, route tables, NAT gateways
  security.tf          Security groups
  iam.tf               IAM roles for ECS tasks, Lambda, etc.
  compute.tf           ECS Fargate / EC2 / Lambda (application tier)
  data.tf              RDS Aurora, ElastiCache, S3 buckets
  observability.tf     CloudWatch, alarms, dashboards
  README.md
```

## Demo Structure

```
demo/
  README.md            Demo overview, setup steps, talking points
  setup.sh             One-command demo environment setup
  teardown.sh          Clean up demo resources
  data-generator/      Python/Java data generator for realistic sample data
    producer.py        Kafka producer with Schema Registry integration
    schemas/           Avro/Protobuf schemas for demo topics
  consumers/           Sample consumers showing real-time processing
    flink-queries.sql  Flink SQL statements for stream processing demo
    ksql-queries.sql   ksqlDB queries (alternative to Flink)
  dashboards/          Grafana or Confluent Cloud dashboard configs
  talking-points.md    Slide-by-slide talking points for the demo
```
