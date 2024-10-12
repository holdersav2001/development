from confluent_kafka import Consumer, KafkaError
import json

def process_trade_event(event):
    # Process the trade event
    # This is a placeholder and should be replaced with actual processing logic
    print(f"Processing trade event: {event}")

def main():
    # Kafka consumer configuration
    conf = {
        'bootstrap.servers': 'localhost:9092',
        'group.id': 'trade_event_processor',
        'auto.offset.reset': 'earliest'
    }

    # Create Consumer instance
    consumer = Consumer(conf)

    # Subscribe to the Debezium topic for trade_events
    consumer.subscribe(['dbserver1.public.trade_events'])

    try:
        while True:
            msg = consumer.poll(1.0)

            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    continue
                else:
                    print(f"Error: {msg.error()}")
                    break

            # Decode the Debezium message
            event = json.loads(msg.value().decode('utf-8'))

            # Check if it's an insert operation
            if event['op'] == 'c':  # 'c' stands for create/insert in Debezium
                trade_event = event['after']
                process_trade_event(trade_event)

    except KeyboardInterrupt:
        pass
    finally:
        # Close down consumer to commit final offsets.
        consumer.close()

if __name__ == "__main__":
    main()
