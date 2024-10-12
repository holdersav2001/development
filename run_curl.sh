#!/bin/bash

curl -H "Content-Type: application/json" -X POST http://localhost:8083/connectors --data '{
    "name": "postgresql-financial-conn",
    "config": { 
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "topic.prefix": "cdc",
        "database.user": "postgres",
        "database.dbname": "financial_db",
        "database.hostname": "postgres",
        "database.password": "postgres",
        "name": "postgresql-financial-conn",
        "plugin.name": "pgoutput",
        "decimal.handling.mode": "string"
    }
}'
