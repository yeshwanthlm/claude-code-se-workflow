#!/bin/bash
set -e

echo "🚀 Setting up Confluent Cloud demo environment..."
echo ""

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "❌ Error: terraform is required but not installed. Install from https://terraform.io"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "❌ Error: jq is required but not installed. Install: brew install jq (Mac) or apt-get install jq (Linux)"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "❌ Error: python3 is required but not installed."; exit 1; }

# Check Confluent Cloud credentials
if [ -z "$TF_VAR_confluent_cloud_api_key" ] || [ -z "$TF_VAR_confluent_cloud_api_secret" ]; then
  echo "❌ Error: Confluent Cloud credentials not set"
  echo ""
  echo "Set environment variables:"
  echo "  export TF_VAR_confluent_cloud_api_key='<your-cloud-api-key>'"
  echo "  export TF_VAR_confluent_cloud_api_secret='<your-cloud-api-secret>'"
  echo ""
  echo "Create a Cloud API Key at: https://confluent.cloud/settings/api-keys"
  exit 1
fi

# Step 1: Deploy Confluent Cloud infrastructure with Terraform
echo "📦 Deploying Confluent Cloud resources (this takes 5-10 minutes)..."
cd ../confluent-terraform
terraform init -upgrade
terraform apply -auto-approve
terraform output -json > ../demo/terraform-outputs.json
cd ../demo

# Step 2: Extract connection details
echo "🔑 Extracting connection details..."
BOOTSTRAP_SERVERS=$(jq -r '.bootstrap_servers.value' terraform-outputs.json)
SCHEMA_REGISTRY_URL=$(jq -r '.schema_registry_url.value' terraform-outputs.json)
KAFKA_API_KEY=$(jq -r '.kafka_api_key.value' terraform-outputs.json)
KAFKA_API_SECRET=$(jq -r '.kafka_api_secret.value' terraform-outputs.json)
SR_API_KEY=$(jq -r '.schema_registry_api_key.value' terraform-outputs.json)
SR_API_SECRET=$(jq -r '.schema_registry_api_secret.value' terraform-outputs.json)

# Step 3: Create client.properties for data generator
echo "⚙️  Configuring data generator..."
cat > data-generator/client.properties <<EOF
# Kafka cluster connection
bootstrap.servers=$BOOTSTRAP_SERVERS
security.protocol=SASL_SSL
sasl.mechanisms=PLAIN
sasl.username=$KAFKA_API_KEY
sasl.password=$KAFKA_API_SECRET

# Schema Registry connection
schema.registry.url=$SCHEMA_REGISTRY_URL
basic.auth.credentials.source=USER_INFO
basic.auth.user.info=$SR_API_KEY:$SR_API_SECRET
EOF

# Step 4: Install Python dependencies
echo "📦 Installing Python dependencies..."
cd data-generator
python3 -m pip install -r requirements.txt --quiet
cd ..

# Step 5: Start data generator in background
echo "📊 Starting data generator..."
cd data-generator
nohup python3 producer.py > producer.log 2>&1 &
PRODUCER_PID=$!
echo $PRODUCER_PID > producer.pid
cd ..

echo ""
echo "✅ Demo environment ready!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Confluent Cloud Cluster"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  URL: https://confluent.cloud"
echo "  Bootstrap Servers: $BOOTSTRAP_SERVERS"
echo "  Kafka API Key: $KAFKA_API_KEY"
echo "  Schema Registry: $SCHEMA_REGISTRY_URL"
echo ""
echo "📊 Data Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Status: Running (PID: $PRODUCER_PID)"
echo "  Log file: data-generator/producer.log"
echo "  To view logs: tail -f data-generator/producer.log"
echo ""
echo "🎯 Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1. Open Confluent Cloud UI: https://confluent.cloud"
echo "  2. Navigate to: Environment → Cluster → Topics"
echo "  3. Click on a topic → Messages tab to see events flowing"
echo "  4. Review talking-points.md for demo script"
echo ""
echo "  To stop the demo: ./teardown.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
