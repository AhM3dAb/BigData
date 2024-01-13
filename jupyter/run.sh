#!/bin/bash

echo "Starting jupyter notebook..."
sudo chown jupyter:jupyter -R /home/jupyter/
mkdir /home/jupyter/notebook
mkdir /home/jupyter/.local
export XDG_RUNTIME_DIR=""
chmod -R 755 /home/jupyter/.local
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' --notebook-dir=/home/jupyter/notebook