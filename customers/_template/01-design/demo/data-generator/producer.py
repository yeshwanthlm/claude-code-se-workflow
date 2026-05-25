#!/usr/bin/env python3
"""
Confluent Cloud Demo Data Generator
Produces realistic sample events to Kafka with Avro schemas and Schema Registry integration.

Customize this for the customer's industry and use case.
"""
import json
import time
import random
import signal
import sys
from datetime import datetime, timezone
from confluent_kafka import Producer, SerializingProducer
from confluent_kafka.serialization import StringSerializer, SerializationContext, MessageField
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer

# Global flag for graceful shutdown
running = True

def signal_handler(sig, frame):
    global running
    print("\n🛑 Shutting down producer...")
    running = False

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def read_config(config_file='client.properties'):
    """Load client configuration from properties file"""
    config = {}
    with open(config_file) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                if '=' in line:
                    key, value = line.split('=', 1)
                    config[key] = value
    return config

def load_avro_schema(schema_file):
    """Load Avro schema from file"""
    with open(schema_file) as f:
        return f.read()

def delivery_report(err, msg):
    """Kafka delivery callback"""
    if err:
        print(f"❌ Delivery failed: {err}")
    else:
        print(f"✅ Message delivered to {msg.topic()} [{msg.partition()}] @ offset {msg.offset()}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Event Generators (Customize for Customer Use Case)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def generate_user_event():
    """Generate user activity event (e-commerce, media, SaaS)"""
    event_types = ['page_view', 'click', 'search', 'add_to_cart', 'purchase', 'video_play', 'video_pause']
    weights = [30, 25, 15, 10, 5, 10, 5]  # page_view is most common

    user_id = f"user_{random.randint(1, 1000)}"
    event_type = random.choices(event_types, weights=weights)[0]

    event = {
        'user_id': user_id,
        'event_id': f"evt_{int(time.time() * 1000)}_{random.randint(1000, 9999)}",
        'event_type': event_type,
        'timestamp': int(datetime.now(timezone.utc).timestamp() * 1000),
        'session_id': f"session_{random.randint(1, 100)}",
        'page': f"/page/{random.randint(1, 50)}",
        'device': random.choice(['mobile', 'desktop', 'tablet']),
        'country': random.choice(['US', 'UK', 'DE', 'FR', 'JP', 'BR', 'IN', 'AU']),
    }

    # Add fields specific to event type
    if event_type == 'purchase':
        event['amount'] = round(random.uniform(10, 500), 2)
        event['currency'] = 'USD'
        event['items'] = random.randint(1, 5)
    elif event_type == 'search':
        event['search_query'] = random.choice(['laptop', 'shoes', 'camera', 'book', 'headphones'])

    return event

def generate_transaction_event():
    """Generate financial transaction event (banking, fintech, payments)"""
    transaction_types = ['purchase', 'withdrawal', 'transfer', 'deposit', 'payment']

    event = {
        'transaction_id': f"txn_{int(time.time() * 1000)}_{random.randint(1000, 9999)}",
        'user_id': f"user_{random.randint(1, 500)}",
        'transaction_type': random.choice(transaction_types),
        'amount': round(random.uniform(5, 5000), 2),
        'currency': random.choice(['USD', 'EUR', 'GBP', 'JPY']),
        'timestamp': int(datetime.now(timezone.utc).timestamp() * 1000),
        'merchant': random.choice(['Amazon', 'Walmart', 'Starbucks', 'Shell', 'Best Buy', 'Target']),
        'location': random.choice(['New York, NY', 'London, UK', 'Tokyo, JP', 'San Francisco, CA', 'Miami, FL']),
        'card_last_four': f"{random.randint(1000, 9999)}",
    }

    # Occasional fraud pattern: high-value transaction from unusual location
    if random.random() < 0.02:  # 2% fraud rate
        event['amount'] = round(random.uniform(2000, 10000), 2)
        event['location'] = random.choice(['Moscow, RU', 'Lagos, NG', 'Unknown'])

    return event

def generate_iot_sensor_event():
    """Generate IoT sensor reading event (manufacturing, smart city, energy)"""
    sensor_types = ['temperature', 'humidity', 'pressure', 'vibration', 'power_consumption']

    sensor_id = f"sensor_{random.randint(1, 100)}"
    sensor_type = random.choice(sensor_types)

    event = {
        'sensor_id': sensor_id,
        'sensor_type': sensor_type,
        'timestamp': int(datetime.now(timezone.utc).timestamp() * 1000),
        'location': f"Zone_{random.choice(['A', 'B', 'C', 'D'])}",
        'device_id': f"device_{random.randint(1, 20)}",
    }

    # Sensor-specific readings
    if sensor_type == 'temperature':
        event['value'] = round(random.uniform(15, 35), 2)  # Celsius
        event['unit'] = 'C'
    elif sensor_type == 'humidity':
        event['value'] = round(random.uniform(30, 80), 2)  # Percentage
        event['unit'] = '%'
    elif sensor_type == 'pressure':
        event['value'] = round(random.uniform(980, 1020), 2)  # hPa
        event['unit'] = 'hPa'
    elif sensor_type == 'vibration':
        event['value'] = round(random.uniform(0, 10), 2)  # mm/s
        event['unit'] = 'mm/s'
    elif sensor_type == 'power_consumption':
        event['value'] = round(random.uniform(0, 500), 2)  # Watts
        event['unit'] = 'W'

    # Occasional anomaly (high value)
    if random.random() < 0.05:  # 5% anomaly rate
        event['value'] = event['value'] * 2

    return event

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main Producer Logic
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def main():
    global running

    # Load configuration
    config = read_config('client.properties')

    # Schema Registry client
    schema_registry_conf = {
        'url': config['schema.registry.url'],
        'basic.auth.user.info': config['basic.auth.user.info']
    }
    schema_registry_client = SchemaRegistryClient(schema_registry_conf)

    # Load Avro schema (customize based on event type)
    schema_str = load_avro_schema('schemas/user-event.avsc')
    avro_serializer = AvroSerializer(schema_registry_client, schema_str)

    # Kafka producer config
    producer_conf = {
        'bootstrap.servers': config['bootstrap.servers'],
        'security.protocol': config.get('security.protocol', 'SASL_SSL'),
        'sasl.mechanisms': config.get('sasl.mechanisms', 'PLAIN'),
        'sasl.username': config['sasl.username'],
        'sasl.password': config['sasl.password'],
        'client.id': 'demo-producer',
        'acks': 'all',
        'compression.type': 'snappy',
        'linger.ms': 100,
        'batch.size': 16384,
    }

    # Create SerializingProducer
    producer = SerializingProducer({
        **producer_conf,
        'key.serializer': StringSerializer('utf_8'),
        'value.serializer': avro_serializer
    })

    print("📊 Starting Confluent Cloud demo data generator...")
    print(f"   Topic: user-events")
    print(f"   Bootstrap Servers: {config['bootstrap.servers']}")
    print(f"   Schema Registry: {config['schema.registry.url']}")
    print("")
    print("   Press Ctrl+C to stop")
    print("")

    message_count = 0
    topic = 'user-events'

    try:
        while running:
            # Generate event (customize for use case)
            event = generate_user_event()
            # event = generate_transaction_event()
            # event = generate_iot_sensor_event()

            # Produce to Kafka
            producer.produce(
                topic=topic,
                key=event.get('user_id', event.get('sensor_id', 'key')),
                value=event,
                on_delivery=delivery_report
            )

            producer.poll(0)  # Serve delivery callbacks

            message_count += 1
            if message_count % 100 == 0:
                print(f"📊 Produced {message_count} events...")

            # Adjust sleep time for desired throughput
            # 0.1 = ~10 events/sec, 0.01 = ~100 events/sec
            time.sleep(0.1)

    except KeyboardInterrupt:
        print("\n🛑 Shutting down producer...")
    finally:
        print(f"\n📊 Flushing {producer} messages...")
        producer.flush(timeout=30)
        print(f"✅ Producer stopped. Total messages produced: {message_count}")

if __name__ == '__main__':
    main()
