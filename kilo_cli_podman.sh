podman run -it --rm \
	-v $(pwd):/workspace:Z \
	-v $HOME/.agents:/root/.agents:Z \
	-w /workspace \
	kilo-env
