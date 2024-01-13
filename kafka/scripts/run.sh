#!/bin/bash
echo "Starting Kafka worker node..."
file_path="/tmp/clusterID/clusterID"
interval=5  # wait interval in seconds

while [ ! -e "$file_path" ] || [ ! -s "$file_path" ]; do
  echo "Waiting for $file_path to be created..."
  sleep $interval
done

#replace environment variables
envsubst < $KAFKA_CONF_DIR/server.properties > $KAFKA_HOME/config/server.properties
cat "$file_path"
# KRaft required step: Format the storage directory with a new cluster ID
kafka-storage.sh format --ignore-formatted -t $(cat "$file_path") -c $KAFKA_HOME/config/server.properties
kafka-server-start.sh $KAFKA_HOME/config/server.properties