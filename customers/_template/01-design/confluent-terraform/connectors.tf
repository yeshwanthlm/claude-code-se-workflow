# Confluent Cloud Managed Connectors
# Customize based on customer requirements

# ----------------------------
# Debezium PostgreSQL CDC Source Connector
# ----------------------------
resource "confluent_connector" "postgres_cdc" {
  count = var.enable_postgres_cdc ? 1 : 0

  environment {
    id = confluent_environment.main.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "name"                         = "postgres-cdc-source"
    "connector.class"              = "PostgresCdcSource"
    "kafka.auth.mode"              = "SERVICE_ACCOUNT"
    "kafka.service.account.id"     = confluent_service_account.connectors.id
    "database.hostname"            = var.postgres_host
    "database.port"                = "5432"
    "database.user"                = var.postgres_user
    "database.password"            = var.postgres_password
    "database.dbname"              = var.postgres_dbname
    "database.server.name"         = var.postgres_server_name
    "table.include.list"           = var.postgres_table_include_list  # e.g., "public.customers,public.orders"
    "plugin.name"                  = "pgoutput"                        # PostgreSQL 10+ logical replication
    "publication.autocreate.mode"  = "filtered"
    "slot.name"                    = "confluent_cdc_slot"
    "snapshot.mode"                = "initial"                         # initial, never, when_needed
    "output.data.format"           = "AVRO"
    "output.key.format"            = "AVRO"
    "after.state.only"             = "true"                            # Only capture after state (not before)
    "tasks.max"                    = "1"
  }

  depends_on = [
    confluent_kafka_cluster.main,
    confluent_service_account.connectors,
    confluent_role_binding.connectors_cluster_admin
  ]
}

# ----------------------------
# Debezium MySQL CDC Source Connector
# ----------------------------
resource "confluent_connector" "mysql_cdc" {
  count = var.enable_mysql_cdc ? 1 : 0

  environment {
    id = confluent_environment.main.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "name"                         = "mysql-cdc-source"
    "connector.class"              = "MySqlCdcSource"
    "kafka.auth.mode"              = "SERVICE_ACCOUNT"
    "kafka.service.account.id"     = confluent_service_account.connectors.id
    "database.hostname"            = var.mysql_host
    "database.port"                = "3306"
    "database.user"                = var.mysql_user
    "database.password"            = var.mysql_password
    "database.server.name"         = var.mysql_server_name
    "table.include.list"           = var.mysql_table_include_list
    "snapshot.mode"                = "initial"
    "output.data.format"           = "AVRO"
    "output.key.format"            = "AVRO"
    "after.state.only"             = "true"
    "tasks.max"                    = "1"
  }

  depends_on = [
    confluent_kafka_cluster.main,
    confluent_service_account.connectors
  ]
}

# ----------------------------
# S3 Sink Connector (Event Archive)
# ----------------------------
resource "confluent_connector" "s3_sink" {
  count = var.enable_s3_sink ? 1 : 0

  environment {
    id = confluent_environment.main.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "name"                    = "s3-sink"
    "connector.class"         = "S3_SINK"
    "kafka.auth.mode"         = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "topics"                  = var.s3_sink_topics  # Comma-separated list
    "input.data.format"       = "AVRO"
    "output.data.format"      = "AVRO"
    "s3.bucket.name"          = var.s3_bucket_name
    "s3.region"               = var.region
    "aws.access.key.id"       = var.aws_access_key_id
    "aws.secret.access.key"   = var.aws_secret_access_key
    "time.interval"           = "HOURLY"           # HOURLY, DAILY, or time in seconds
    "flush.size"              = "1000"             # Flush after N records
    "path.format"             = "'year'=YYYY/'month'=MM/'day'=dd/'hour'=HH"  # Hive-style partitioning
    "partitioner.class"       = "io.confluent.connect.storage.partitioner.TimeBasedPartitioner"
    "tasks.max"               = "1"
  }

  depends_on = [
    confluent_kafka_cluster.main,
    confluent_kafka_topic.topics,
    confluent_service_account.connectors
  ]
}

# ----------------------------
# Snowflake Sink Connector (Data Warehouse)
# ----------------------------
resource "confluent_connector" "snowflake_sink" {
  count = var.enable_snowflake_sink ? 1 : 0

  environment {
    id = confluent_environment.main.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  config_sensitive = {
    "snowflake.private.key" = var.snowflake_private_key
  }

  config_nonsensitive = {
    "name"                       = "snowflake-sink"
    "connector.class"            = "SnowflakeSink"
    "kafka.auth.mode"            = "SERVICE_ACCOUNT"
    "kafka.service.account.id"   = confluent_service_account.connectors.id
    "topics"                     = var.snowflake_sink_topics
    "input.data.format"          = "AVRO"
    "snowflake.url.name"         = var.snowflake_url           # e.g., "https://xy12345.snowflakecomputing.com"
    "snowflake.user.name"        = var.snowflake_user
    "snowflake.database.name"    = var.snowflake_database
    "snowflake.schema.name"      = var.snowflake_schema
    "snowflake.private.key.passphrase" = var.snowflake_private_key_passphrase
    "buffer.count.records"       = "10000"
    "buffer.flush.time"          = "60"                        # Flush every 60 seconds
    "buffer.size.bytes"          = "5000000"                   # 5MB buffer
    "tasks.max"                  = "2"
  }

  depends_on = [
    confluent_kafka_cluster.main,
    confluent_service_account.connectors
  ]
}

# ----------------------------
# Elasticsearch Sink Connector (Search Indexing)
# ----------------------------
resource "confluent_connector" "elasticsearch_sink" {
  count = var.enable_elasticsearch_sink ? 1 : 0

  environment {
    id = confluent_environment.main.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  config_sensitive = {
    "connection.password" = var.elasticsearch_password
  }

  config_nonsensitive = {
    "name"                    = "elasticsearch-sink"
    "connector.class"         = "ElasticsearchSink"
    "kafka.auth.mode"         = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "topics"                  = var.elasticsearch_sink_topics
    "input.data.format"       = "AVRO"
    "connection.url"          = var.elasticsearch_url
    "connection.username"     = var.elasticsearch_username
    "type.name"               = "_doc"
    "behavior.on.null.values" = "DELETE"
    "batch.size"              = "2000"
    "linger.ms"               = "1000"
    "tasks.max"               = "1"
  }

  depends_on = [
    confluent_kafka_cluster.main,
    confluent_service_account.connectors
  ]
}

# ----------------------------
# MongoDB Sink Connector (Microservice Database)
# ----------------------------
resource "confluent_connector" "mongodb_sink" {
  count = var.enable_mongodb_sink ? 1 : 0

  environment {
    id = confluent_environment.main.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  config_sensitive = {
    "connection.password" = var.mongodb_password
  }

  config_nonsensitive = {
    "name"                    = "mongodb-sink"
    "connector.class"         = "MongoDbAtlasSink"
    "kafka.auth.mode"         = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "topics"                  = var.mongodb_sink_topics
    "input.data.format"       = "AVRO"
    "connection.host"         = var.mongodb_host
    "connection.user"         = var.mongodb_user
    "database"                = var.mongodb_database
    "collection"              = var.mongodb_collection
    "max.batch.size"          = "1000"
    "tasks.max"               = "1"
  }

  depends_on = [
    confluent_kafka_cluster.main,
    confluent_service_account.connectors
  ]
}

# ----------------------------
# HTTP Sink Connector (Webhook / API)
# ----------------------------
resource "confluent_connector" "http_sink" {
  count = var.enable_http_sink ? 1 : 0

  environment {
    id = confluent_environment.main.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "name"                    = "http-sink"
    "connector.class"         = "HttpSink"
    "kafka.auth.mode"         = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "topics"                  = var.http_sink_topics
    "input.data.format"       = "AVRO"
    "http.api.url"            = var.http_sink_url
    "request.method"          = "POST"
    "headers"                 = "Content-Type:application/json"
    "batch.max.size"          = "100"
    "tasks.max"               = "1"
  }

  depends_on = [
    confluent_kafka_cluster.main,
    confluent_service_account.connectors
  ]
}
