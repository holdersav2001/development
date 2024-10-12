import psycopg2
import psycopg2.extras
from kafka import KafkaProducer
import json

def create_connection():
    return psycopg2.connect(
        dbname="your_database",
        user="your_username",
        password="your_password",
        host="your_host",
        port="your_port"
    )

def start_replication(conn):
    cur = conn.cursor()
    cur.execute("CREATE_REPLICATION_SLOT test_slot TEMPORARY LOGICAL pgoutput")
    cur.execute("START_REPLICATION SLOT test_slot LOGICAL 0/0")

def get_trade_event_table_oid(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT oid FROM pg_class WHERE relname = 'trade_event'")
        result = cur.fetchone()
        return result[0] if result else None

def process_replication_message(msg, trade_event_table_oid):
    # Process the replication message and extract relevant data
    # This is a simplified example and may need to be adjusted based on your specific needs
    if msg.data.startswith(b'BEGIN'):
        return None
    elif msg.data.startswith(b'table'):
        table_oid = int.from_bytes(msg.data[6:10], byteorder='big')
        # Check if the table_oid corresponds to the trade_event table
        if table_oid == trade_event_table_oid:
            # Extract and transform the data as needed
            # This is a placeholder and should be replaced with actual data extraction logic
            transformed_data = {"event": "trade", "data": msg.data.decode('utf-8')}
            return transformed_data
    return None

def send_to_kafka(producer, topic, data):
    producer.send(topic, value=json.dumps(data).encode('utf-8'))
    producer.flush()

def main():
    conn = create_connection()
    trade_event_table_oid = get_trade_event_table_oid(conn)
    if trade_event_table_oid is None:
        print("Error: Unable to find OID for trade_event table")
        return
    
    start_replication(conn)
    
    kafka_producer = KafkaProducer(bootstrap_servers=['localhost:9092'])
    
    try:
        while True:
            msg = conn.cursor().read_message()
            if msg:
                transformed_data = process_replication_message(msg, trade_event_table_oid)
                if transformed_data:
                    send_to_kafka(kafka_producer, 'trade_event', transformed_data)
    finally:
        conn.close()
        kafka_producer.close()

if __name__ == "__main__":
    main()
