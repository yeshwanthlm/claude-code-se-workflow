# Confluent Cloud Terraform Template

This directory contains Terraform configuration for provisioning Confluent Cloud resources.

## Resources Managed

- **Confluent Environment** — Logical container for all resources
- **Kafka Cluster** — Basic, Standard, or Dedicated cluster
- **Schema Registry** — Centralized schema management (Avro, Protobuf, JSON Schema)
- **Topics** — Kafka topics with partition count, retention, and replication configs
- **Connectors** — Managed source and sink connectors (Debezium CDC, S3, Snowflake, Elasticsearch, etc.)
- **Flink Compute Pool** — Managed Apache Flink for stream processing
- **Flink Statements** — Flink SQL queries for real-time transformations
- **Service Accounts** — Identity for applications, connectors, Flink jobs
- **RBAC Role Bindings** — Access control (CloudClusterAdmin, DeveloperRead, DeveloperWrite, etc.)
- **API Keys** — Kafka API keys, Schema Registry API keys, Flink API keys

## Prerequisites

1. **Confluent Cloud Account**
   - Sign up at https://confluent.cloud
   - Create a Cloud API Key (Organization Admin or Environment Admin role)
     - Navigate to: Settings → API Keys → Add key → Cloud API Key

2. **Terraform**
   - Version >= 1.6.0
   - Install: https://developer.hashicorp.com/terraform/downloads

3. **AWS Account** (for connectors that access AWS resources)
   - S3 bucket for S3 Sink connector
   - IAM credentials with S3 write permissions

## Directory Structure

```
confluent-terraform/
  main.tf              Provider configuration, Confluent Cloud credentials
  variables.tf         Input variables (environment name, cluster type, region, etc.)
  outputs.tf           Outputs (bootstrap servers, Schema Registry URL, API keys)
  locals.tf            Derived values, naming conventions
  environment.tf       confluent_environment
  cluster.tf           confluent_kafka_cluster
  schema-registry.tf   confluent_schema_registry_cluster
  topics.tf            confluent_kafka_topic (all topics)
  connectors.tf        confluent_connector (source and sink connectors)
  flink.tf             confluent_flink_compute_pool, confluent_flink_statement
  iam.tf               confluent_service_account, confluent_role_binding, confluent_api_key
  stream-governance.tf (optional) confluent_tag, confluent_business_metadata
  README.md            This file
  terraform.tfvars.example  Example variable values (copy to terraform.tfvars)
```

## Getting Started

### 1. Create Confluent Cloud API Key

1. Log in to https://confluent.cloud
2. Navigate to **Settings → API Keys**
3. Click **Add key** → Select **Cloud API Key** (not Kafka API Key)
4. Save the **Key** and **Secret** (you won't see the secret again)

### 2. Configure Variables

Copy `terraform.tfvars.example` to `terraform.tfvars`:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your values:

```hcl
# Confluent Cloud credentials
confluent_cloud_api_key    = "YOUR_CLOUD_API_KEY"
confluent_cloud_api_secret = "YOUR_CLOUD_API_SECRET"

# Environment config
environment_name = "prod"
cluster_type     = "DEDICATED"  # BASIC, STANDARD, DEDICATED
region           = "us-east-1"
cku_count        = 1

# Enable/disable connectors
enable_postgres_cdc    = true
enable_s3_sink         = true
enable_snowflake_sink  = false

# Enable/disable Flink
enable_flink = true
flink_max_cfu = 10
```

### 3. Initialize Terraform

```bash
terraform init
```

This downloads the Confluent provider and initializes the working directory.

### 4. Plan

```bash
terraform plan
```

Review the resources that will be created. Terraform will show:
- Kafka cluster (type, region, CKUs)
- Schema Registry
- Topics (count, partition count, retention)
- Connectors (sources, sinks)
- Flink compute pool
- Service accounts
- RBAC role bindings
- API keys

### 5. Apply

```bash
terraform apply
```

Type `yes` to confirm. Terraform will create all resources.

**Note:** Cluster creation takes 5-10 minutes. Dedicated clusters take longer than Standard.

### 6. Get Outputs

```bash
terraform output
```

Key outputs:
- `bootstrap_servers` — Kafka bootstrap servers (use for producers/consumers)
- `schema_registry_url` — Schema Registry REST endpoint
- `kafka_api_key` — Kafka API key ID
- `kafka_api_secret` — Kafka API secret (sensitive)
- `schema_registry_api_key` — Schema Registry API key ID
- `schema_registry_api_secret` — Schema Registry API secret (sensitive)

Save outputs to a file:

```bash
terraform output -json > outputs.json
```

### 7. Test Connectivity

Create a `client.properties` file for Kafka clients:

```properties
bootstrap.servers=<bootstrap_servers from output>
security.protocol=SASL_SSL
sasl.mechanisms=PLAIN
sasl.username=<kafka_api_key from output>
sasl.password=<kafka_api_secret from output>
schema.registry.url=<schema_registry_url from output>
basic.auth.credentials.source=USER_INFO
basic.auth.user.info=<schema_registry_api_key>:<schema_registry_api_secret>
```

Test with `kafka-console-producer`:

```bash
kafka-console-producer --bootstrap-server <bootstrap_servers> \
  --topic user-events \
  --producer.config client.properties
```

### 8. Destroy (when done)

```bash
terraform destroy
```

Type `yes` to confirm. This will delete all resources.

**Warning:** Set `prevent_destroy = true` in production to prevent accidental deletion.

## Cost Estimate

| Resource | Unit | Cost (approx) |
|----------|------|---------------|
| Kafka Cluster (Dedicated, 1 CKU) | $1.50/hour | ~$1,080/month |
| Schema Registry (Essentials) | Included | $0/month |
| Connectors (1 task each) | $0.25/task/hour | ~$180/task/month |
| Flink (10 CFUs) | $0.52/CFU/hour | ~$3,740/month |
| **Total (example)** | | **~$5,000-$6,000/month** |

Use the Confluent Cloud Pricing Calculator for accurate estimates:
https://www.confluent.io/confluent-cloud/pricing/

## Customizing This Template

### Add More Topics

Edit `topics.tf` and add to the `local.topics` map:

```hcl
locals {
  topics = {
    "my-new-topic" = {
      partitions         = 6
      retention_ms       = 604800000  # 7 days
      cleanup_policy     = "delete"
      min_insync_replicas = 2
    }
  }
}
```

### Add More Connectors

Edit `connectors.tf` and uncomment or add new connector resources.

For Databricks Delta Lake Sink:

```hcl
resource "confluent_connector" "databricks_sink" {
  # ... (see Confluent documentation)
}
```

### Add More Flink Statements

Edit `flink.tf` and add new `confluent_flink_statement` resources.

## Troubleshooting

### Error: "Invalid API Key"
- Ensure you're using a **Cloud API Key** (not Kafka API Key) for the Terraform provider
- Verify the key has OrganizationAdmin or EnvironmentAdmin permissions

### Error: "Cluster creation failed"
- Check Confluent Cloud quotas (max clusters per environment)
- Verify the region is supported for the cluster type

### Error: "Connector task failed"
- Check connector logs in Confluent Cloud UI
- Verify source database connectivity (firewall, network policies)
- For CDC connectors, verify database replication is enabled (PostgreSQL: `wal_level = logical`, MySQL: `binlog_format = ROW`)

### Flink Statement Errors
- Verify topic schemas exist in Schema Registry
- Check Flink SQL syntax (use Confluent Cloud UI to test queries first)
- Ensure Flink service account has correct RBAC permissions

## References

- [Confluent Terraform Provider Documentation](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs)
- [Confluent Cloud Documentation](https://docs.confluent.io/cloud/current/)
- [Confluent Cloud Pricing](https://www.confluent.io/confluent-cloud/pricing/)
- [Apache Flink SQL Reference](https://docs.confluent.io/cloud/current/flink/reference/overview.html)
- [Kafka Connect Connector Catalog](https://www.confluent.io/product/connectors/)
