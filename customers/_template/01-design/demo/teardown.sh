#!/bin/bash
set -e

echo "🛑 Tearing down demo environment..."
echo ""

# Step 1: Stop data generator
if [ -f data-generator/producer.pid ]; then
  PRODUCER_PID=$(cat data-generator/producer.pid)
  if kill -0 $PRODUCER_PID 2>/dev/null; then
    echo "⏹️  Stopping data generator (PID: $PRODUCER_PID)..."
    kill $PRODUCER_PID 2>/dev/null || true
    sleep 2
    # Force kill if still running
    kill -9 $PRODUCER_PID 2>/dev/null || true
  fi
  rm -f data-generator/producer.pid
  echo "✅ Data generator stopped"
else
  echo "ℹ️  Data generator was not running"
fi

# Step 2: Destroy Confluent Cloud infrastructure
echo "🗑️  Destroying Confluent Cloud resources..."
echo "   (This will delete the Kafka cluster, connectors, Flink, and all data)"
echo ""
read -p "Are you sure you want to destroy all resources? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "❌ Teardown cancelled"
  exit 0
fi

cd ../confluent-terraform
terraform destroy -auto-approve
cd ../demo

# Step 3: Clean up
echo "🧹 Cleaning up local files..."
rm -f terraform-outputs.json
rm -f data-generator/client.properties
rm -f data-generator/producer.log

echo ""
echo "✅ Demo environment destroyed"
echo ""
echo "All Confluent Cloud resources have been deleted."
echo "No ongoing charges will occur."
