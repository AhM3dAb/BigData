#!/bin/bash

echo "Starting Zookeeper worker node..."
sudo chown jupyter:jupyter -R /home/jupyter/
bash $ZOOKEEPER_HOME/conf/zookeeper_init.sh 
$ZOOKEEPER_HOME/bin/zkServer.sh start-foreground
