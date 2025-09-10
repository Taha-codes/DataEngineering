## DataEngineering – CDC Pipeline (Postgres → Kafka → HDFS)

This project provides a containerized Change Data Capture (CDC) pipeline that streams real-time changes from a PostgreSQL database into Apache Kafka and lands them in Apache HDFS via Kafka Connect. It is ideal for prototyping data lakes, real-time analytics, and event-driven architectures.

### Architecture

PostgreSQL → Debezium (Kafka Connect source) → Kafka → Kafka Connect HDFS sink → HDFS

### What’s included

- Postgres 15 preloaded with an `ecommerce` schema and seed data
- Debezium PostgreSQL source connector (installed into Kafka Connect at startup)
- Kafka (with Zookeeper) for streaming change events
- Kafka Connect (REST API on port 8083) to run source/sink connectors
- HDFS (NameNode, DataNode, and a lightweight client) as the data lake destination

---

## Quickstart

### 1) Prerequisites

- Docker and Docker Compose installed
- macOS/Linux shell

### 2) Start the stack

Run from the project root or the `cdc-pipeline` directory:

```bash
cd cdc-pipeline
docker compose up -d
```

Startup notes:
- Kafka Connect installs the Debezium and HDFS connectors on first run; give it ~1–2 minutes.
- You can watch logs if needed:
  - `docker logs -f cdc-kafka-connect`

### 3) Verify services

- Containers: `docker ps`
- Kafka Connect health: `curl http://localhost:8083/connectors | jq .` (empty list on first run)

### 4) Register the Debezium Postgres connector

There is a ready-to-use config at `cdc-pipeline/debezium-postgres-connector.json`.

Important: Ensure the `publication.name` matches the publication created in Postgres. The SQL creates `dbz_publication` in `cdc-pipeline/02-cdc-setup.sql`. If the JSON differs, update it before posting.

```bash
cd cdc-pipeline
curl -s -X POST \
  -H "Content-Type: application/json" \
  --data @debezium-postgres-connector.json \
  http://localhost:8083/connectors | jq .

# Check status
curl -s http://localhost:8083/connectors/postgres-connector/status | jq .
```

### 5) (Optional) Add the HDFS sink connector

The image already includes the Kafka Connect HDFS plugin. You can create an HDFS sink connector (example minimal payload):

```bash
curl -s -X POST http://localhost:8083/connectors -H 'Content-Type: application/json' -d '{
  "name": "hdfs-sink",
  "config": {
    "connector.class": "io.confluent.connect.hdfs.HdfsSinkConnector",
    "tasks.max": "1",
    "topics.regex": "cdc_demo\\..*",  
    "hdfs.url": "hdfs://namenode:9000",
    "flush.size": "3",
    "rotate.interval.ms": "60000",
    "format.class": "io.confluent.connect.hdfs.avro.AvroFormat",
    "partitioner.class": "io.confluent.connect.storage.partitioner.TimeBasedPartitioner",
    "path.format": "'year'=YYYY/'month'=MM/'day'=dd/'hour'=HH",
    "locale": "en",
    "timezone": "UTC",
    "partition.duration.ms": "3600000"
  }
}' | jq .
```

You can also tune this to write JSON if preferred by using the JSON converter/format.

---

## Test the pipeline

### Produce CDC events

Insert/update/delete rows in Postgres and observe messages in Kafka.

Example inserts:

```bash
# Open a psql shell in the Postgres container
docker exec -it cdc-postgres psql -U postgres -d cdc_demo

-- Inside psql:
INSERT INTO ecommerce.customers (first_name, last_name, email, phone)
VALUES ('Alice', 'Taylor', 'alice.taylor@example.com', '555-777-8888');

UPDATE ecommerce.products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
\q
```

### Inspect Kafka topics

```bash
# List topics
docker exec -it cdc-kafka kafka-topics --bootstrap-server kafka:29092 --list

# Consume from a specific topic
docker exec -it cdc-kafka kafka-console-consumer \
  --bootstrap-server kafka:29092 \
  --topic cdc_demo.ecommerce.customers \
  --from-beginning
```

### Browse data in HDFS

Web UI: `http://localhost:9870`

CLI:

```bash
# Open a shell in the HDFS client
docker exec -it cdc-hdfs-client bash

# Inside container
hdfs dfs -ls /
hdfs dfs -ls /topics
hdfs dfs -ls -R /topics
exit
```

---

## Services and Ports

- Postgres: `localhost:5432`
- Zookeeper: `localhost:2181`
- Kafka broker (external): `localhost:9092`
- Kafka broker (internal to Docker network): `kafka:29092`
- Kafka Connect REST API: `http://localhost:8083`
- HDFS NameNode UI: `http://localhost:9870`
- HDFS IPC: `9000` (internal)
- HDFS DataNode UI: `http://localhost:9864`

---

## Data model

Defined in `cdc-pipeline/01-init.sql`:
- `ecommerce.customers`
- `ecommerce.products`
- `ecommerce.orders`
- `ecommerce.order_items`

CDC prerequisites in `cdc-pipeline/02-cdc-setup.sql`:
- Creates role `debezium` with replication
- Grants required privileges
- Creates publication `dbz_publication`

Note: Ensure the Debezium connector config `publication.name` matches `dbz_publication`.

---

## Operations

### Stop and clean up

```bash
cd cdc-pipeline
docker compose down -v
```

### Useful troubleshooting

- Kafka Connect logs: `docker logs -f cdc-kafka-connect`
- Postgres logs: `docker logs -f cdc-postgres`
- Verify connectors: `curl http://localhost:8083/connectors | jq .`
- Connector status: `curl http://localhost:8083/connectors/<name>/status | jq .`

Common issues:
- Publication mismatch: Update `publication.name` in the Debezium JSON to `dbz_publication` (or change SQL accordingly).
- Plugin installation time: First boot of Kafka Connect may take a minute while it installs connectors.
- Ports already in use: Stop local services using 5432/9092/8083/9870 or adjust ports in `cdc-pipeline/docker-compose.yml`.

---

## Repository layout

```
DataEngineering/
  cdc-pipeline/
    docker-compose.yml
    01-init.sql
    02-cdc-setup.sql
    debezium-postgres-connector.json
    hdfs/
    postgres-config/
    kafka-connect-data/
    scripts/
```

---

## License

MIT (or your preferred license). Replace this section if different.
