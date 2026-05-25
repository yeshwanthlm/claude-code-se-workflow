# Confluent Cloud Apache Flink (Managed Stream Processing)
# Customize based on customer use case

# ----------------------------
# Flink Compute Pool
# ----------------------------
resource "confluent_flink_compute_pool" "main" {
  count = var.enable_flink ? 1 : 0

  display_name = "${var.environment_name}-flink-pool"
  cloud        = var.cloud_provider
  region       = var.region
  max_cfu      = var.flink_max_cfu  # Maximum CFUs (auto-scales up to this limit)

  environment {
    id = confluent_environment.main.id
  }
}

# ----------------------------
# Data Source for Organization ID (required for Flink statements)
# ----------------------------
data "confluent_organization" "main" {}

# ----------------------------
# Flink Statement: Real-Time User Activity Aggregation
# Example: Tumbling window aggregation (5-minute windows)
# ----------------------------
resource "confluent_flink_statement" "user_activity_aggregation" {
  count = var.enable_flink && var.enable_flink_user_activity_aggregation ? 1 : 0

  organization {
    id = data.confluent_organization.main.id
  }

  environment {
    id = confluent_environment.main.id
  }

  compute_pool {
    id = confluent_flink_compute_pool.main[0].id
  }

  principal {
    id = confluent_service_account.flink_runner.id
  }

  statement = <<-EOT
    -- Real-time user activity metrics (5-minute tumbling windows)
    INSERT INTO user_activity_metrics
    SELECT
      user_id,
      TUMBLE_START(event_time, INTERVAL '5' MINUTE) as window_start,
      TUMBLE_END(event_time, INTERVAL '5' MINUTE) as window_end,
      COUNT(*) as event_count,
      COUNT(DISTINCT session_id) as session_count,
      COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN event_id END) as purchase_count,
      SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) as total_revenue
    FROM user_events
    WHERE event_time IS NOT NULL
    GROUP BY user_id, TUMBLE(event_time, INTERVAL '5' MINUTE);
  EOT

  properties = {
    "sql.current-catalog"  = confluent_environment.main.display_name
    "sql.current-database" = confluent_kafka_cluster.main.display_name
  }

  rest_endpoint = confluent_flink_compute_pool.main[0].rest_endpoint

  credentials {
    key    = confluent_api_key.flink_api_key[0].id
    secret = confluent_api_key.flink_api_key[0].secret
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_service_account.flink_runner,
    confluent_role_binding.flink_runner_environment_admin
  ]

  lifecycle {
    prevent_destroy = false  # Set to true for production
  }
}

# ----------------------------
# Flink Statement: Stream Join (Orders + Customers)
# Example: Enrich order events with customer data
# ----------------------------
resource "confluent_flink_statement" "order_customer_join" {
  count = var.enable_flink && var.enable_flink_order_join ? 1 : 0

  organization {
    id = data.confluent_organization.main.id
  }

  environment {
    id = confluent_environment.main.id
  }

  compute_pool {
    id = confluent_flink_compute_pool.main[0].id
  }

  principal {
    id = confluent_service_account.flink_runner.id
  }

  statement = <<-EOT
    -- Enrich order events with customer information
    INSERT INTO enriched_orders
    SELECT
      o.order_id,
      o.customer_id,
      c.customer_name,
      c.customer_email,
      c.customer_tier,
      o.total_amount,
      o.order_status,
      o.order_time,
      o.items
    FROM orders o
    INNER JOIN customers FOR SYSTEM_TIME AS OF o.order_time AS c
      ON o.customer_id = c.customer_id;
  EOT

  properties = {
    "sql.current-catalog"  = confluent_environment.main.display_name
    "sql.current-database" = confluent_kafka_cluster.main.display_name
  }

  rest_endpoint = confluent_flink_compute_pool.main[0].rest_endpoint

  credentials {
    key    = confluent_api_key.flink_api_key[0].id
    secret = confluent_api_key.flink_api_key[0].secret
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_service_account.flink_runner
  ]
}

# ----------------------------
# Flink Statement: Fraud Detection (Pattern Matching)
# Example: Detect unusual transaction patterns
# ----------------------------
resource "confluent_flink_statement" "fraud_detection" {
  count = var.enable_flink && var.enable_flink_fraud_detection ? 1 : 0

  organization {
    id = data.confluent_organization.main.id
  }

  environment {
    id = confluent_environment.main.id
  }

  compute_pool {
    id = confluent_flink_compute_pool.main[0].id
  }

  principal {
    id = confluent_service_account.flink_runner.id
  }

  statement = <<-EOT
    -- Fraud detection: Flag users with >5 transactions in 1 hour from different locations
    INSERT INTO fraud_alerts
    SELECT
      user_id,
      HOP_START(transaction_time, INTERVAL '5' MINUTE, INTERVAL '1' HOUR) as window_start,
      HOP_END(transaction_time, INTERVAL '5' MINUTE, INTERVAL '1' HOUR) as window_end,
      COUNT(*) as transaction_count,
      COUNT(DISTINCT location) as distinct_locations,
      SUM(amount) as total_amount,
      COLLECT(transaction_id) as transaction_ids,
      'HIGH' as risk_level
    FROM transactions
    WHERE transaction_time IS NOT NULL
    GROUP BY user_id, HOP(transaction_time, INTERVAL '5' MINUTE, INTERVAL '1' HOUR)
    HAVING COUNT(*) > 5 AND COUNT(DISTINCT location) > 2;
  EOT

  properties = {
    "sql.current-catalog"  = confluent_environment.main.display_name
    "sql.current-database" = confluent_kafka_cluster.main.display_name
  }

  rest_endpoint = confluent_flink_compute_pool.main[0].rest_endpoint

  credentials {
    key    = confluent_api_key.flink_api_key[0].id
    secret = confluent_api_key.flink_api_key[0].secret
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_service_account.flink_runner
  ]
}

# ----------------------------
# Flink Statement: Sessionization (User Sessions)
# Example: Detect user sessions with 30-minute inactivity gap
# ----------------------------
resource "confluent_flink_statement" "sessionization" {
  count = var.enable_flink && var.enable_flink_sessionization ? 1 : 0

  organization {
    id = data.confluent_organization.main.id
  }

  environment {
    id = confluent_environment.main.id
  }

  compute_pool {
    id = confluent_flink_compute_pool.main[0].id
  }

  principal {
    id = confluent_service_account.flink_runner.id
  }

  statement = <<-EOT
    -- Sessionization: Group user events into sessions (30-minute inactivity gap)
    INSERT INTO user_sessions
    SELECT
      user_id,
      SESSION_START(event_time, INTERVAL '30' MINUTE) as session_start,
      SESSION_END(event_time, INTERVAL '30' MINUTE) as session_end,
      COUNT(*) as event_count,
      COUNT(DISTINCT page) as page_count,
      MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) as has_purchase,
      SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) as session_revenue
    FROM user_events
    WHERE event_time IS NOT NULL
    GROUP BY user_id, SESSION(event_time, INTERVAL '30' MINUTE);
  EOT

  properties = {
    "sql.current-catalog"  = confluent_environment.main.display_name
    "sql.current-database" = confluent_kafka_cluster.main.display_name
  }

  rest_endpoint = confluent_flink_compute_pool.main[0].rest_endpoint

  credentials {
    key    = confluent_api_key.flink_api_key[0].id
    secret = confluent_api_key.flink_api_key[0].secret
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_service_account.flink_runner
  ]
}

# ----------------------------
# Flink API Key (for Flink compute pool access)
# ----------------------------
resource "confluent_api_key" "flink_api_key" {
  count = var.enable_flink ? 1 : 0

  display_name = "${var.environment_name}-flink-api-key"
  description  = "API Key for Flink compute pool"

  owner {
    id          = confluent_service_account.flink_runner.id
    api_version = confluent_service_account.flink_runner.api_version
    kind        = confluent_service_account.flink_runner.kind
  }

  managed_resource {
    id          = confluent_flink_compute_pool.main[0].id
    api_version = confluent_flink_compute_pool.main[0].api_version
    kind        = confluent_flink_compute_pool.main[0].kind
    environment {
      id = confluent_environment.main.id
    }
  }

  depends_on = [
    confluent_flink_compute_pool.main,
    confluent_service_account.flink_runner,
    confluent_role_binding.flink_runner_environment_admin
  ]
}
