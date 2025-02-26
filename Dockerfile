# Use Confluent's Kafka image as base
FROM confluentinc/cp-kafka:latest

# Switch to root to create directories
USER root

# Set environment variables
ENV KAFKA_NODE_ID=1 \
    KAFKA_PROCESS_ROLES="broker,controller" \
    CLUSTER_ID="ciWo7IWazngRchmPES6q5B==" \
    KAFKA_CONTROLLER_LISTENER_NAMES="CONTROLLER" \
    KAFKA_LISTENER_SECURITY_PROTOCOL_MAP="CONTROLLER:PLAINTEXT,INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT" \
    KAFKA_LISTENERS="INTERNAL://:29092,CONTROLLER://:29093,EXTERNAL://:9092" \
    KAFKA_ADVERTISED_LISTENERS="INTERNAL://localhost:29092,EXTERNAL://localhost:9092" \
    KAFKA_INTER_BROKER_LISTENER_NAME="INTERNAL" \
    KAFKA_CONTROLLER_QUORUM_VOTERS="1@localhost:29093" \
    KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0 \
    KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
    KAFKA_LOG_DIRS="/data/kraft-combined-logs"

# Create necessary directories and set permissions
RUN mkdir -p /data/kraft-combined-logs && \
    chown -R appuser:appuser /data && \
    chmod -R 775 /data

# Expose ports
EXPOSE 9092 29092 29093

# Create a healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD kafka-topics.sh --bootstrap-server localhost:29092 --list || exit 1

# Copy and set permissions for entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chown appuser:appuser /entrypoint.sh

# Switch back to the appuser
USER appuser

ENTRYPOINT ["/entrypoint.sh"]