# Postgres WAL Ingestion with Kafka and Elasticsearch

This project sets up a data pipeline using Debezium for Change Data Capture (CDC) from PostgreSQL, Kafka for message streaming, and Elasticsearch for data storage and visualization.

## Prerequisites

- Docker and Docker Compose installed on your system
- PowerShell (for Windows users)

## Getting Started

1. Start the Docker containers:
   ```
   docker-compose up -d
   ```

2. Wait for all services to be up and running. You can check the status with:
   ```
   docker-compose ps
   ```

3. Configure the Debezium PostgreSQL connector:
   ```
   .\run_curl.ps1
   ```

4. Configure the Elasticsearch Sink connector:
   ```
   .\configure_elasticsearch_sink.ps1
   ```

## Viewing Data in Kibana

1. Open Kibana in your web browser:
   ```
   http://localhost:5601
   ```

2. Create an index pattern:
   - In the left sidebar, click on "Stack Management"
   - Under "Kibana", click on "Index Patterns"
   - Click "Create index pattern"
   - In the "Index pattern name" field, enter "cdc.public.trade_event*"
   - Click "Next step"
   - For the Time field, select "@timestamp" if available, or choose "I don't want to use the Time filter" if not
   - Click "Create index pattern"

3. View your data:
   - In the left sidebar, click on "Discover"
   - In the dropdown menu at the top left, select the index pattern you just created ("cdc.public.trade_event*")
   - You should now see your data in the main panel

4. Explore and visualize your data:
   - Use the search bar at the top to filter your data
   - Click on the arrow next to each field in the left column to add it to your view
   - Create visualizations by clicking "Visualize" in the left sidebar and selecting "Create new visualization"

## Troubleshooting

If you don't see any data in Kibana:

1. Verify data is in Kafka:
   ```
   docker-compose exec broker kafka-console-consumer --bootstrap-server broker:29092 --topic cdc.public.trade_event --from-beginning
   ```

2. Check Elasticsearch indices:
   ```
   curl http://localhost:9200/_cat/indices
   ```

3. Query Elasticsearch directly:
   ```
   curl -X GET "localhost:9200/cdc.public.trade_event*/_search?pretty"
   ```

4. Check Kafka Connect logs:
   ```
   docker-compose logs kafka-connect
   ```

5. Verify the Elasticsearch Sink connector status:
   ```
   curl http://localhost:8083/connectors/elasticsearch-sink/status
   ```

## Stopping the Services

To stop all services, run:
```
docker-compose down
```

To stop the services and remove all data volumes, run:
```
docker-compose down -v
```

For more detailed information about each component, refer to their respective documentation:
- [Debezium](https://debezium.io/documentation/)
- [Kafka](https://kafka.apache.org/documentation/)
- [Kafka Connect](https://docs.confluent.io/platform/current/connect/index.html)
- [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)
