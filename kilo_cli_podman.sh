#!/bin/bash
LOCAL_PATH=$HOME/.local/share/kilo
ROOT=/var/tmp/kilo
mkdir -p $LOCAL_PATH $ROOT

podman run -it --rm \
	-v $(pwd):/workspace:Z \
	-v $HOME/.agents:/root/.agents:Z \
	-v $LOCAL_PATH:/root/.local/share/kilo:Z \
	-v $ROOT:/root:Z \
	-w /workspace \
	-v $HOME/Projects/distrobox:/workspace/distrobox:Z \
	kilo-osbox
