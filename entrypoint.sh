#!/bin/bash

# Update Kafka configuration based on Fly.io environment
if [ ! -z "$FLY_APP_NAME" ]; then
    # Get the public IPv6 address
    export EXTERNAL_IP=$(curl -s "http://169.254.169.254/latest/meta-data/public-ipv6")
    
    # Update the advertised listeners with the actual Fly.io hostname
    export KAFKA_ADVERTISED_LISTENERS="INTERNAL://localhost:29092,EXTERNAL://${FLY_APP_NAME}.fly.dev:9092"
    
    # Update controller quorum voters if running in a cluster
    if [ ! -z "$FLY_REGION" ]; then
        export KAFKA_CONTROLLER_QUORUM_VOTERS="1@${FLY_APP_NAME}.internal:29093"
    fi
fi

# Start Kafka
exec /etc/confluent/docker/run