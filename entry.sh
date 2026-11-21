#!/bin/bash
EXTRA_ARGS=()
BOXNAME="ubuntu-work"
IMGNAME="ubuntu-work"

while [ $# -gt 0 ]; do
	case "$1" in
	-e | --ephemeral)
		EXTRA_ARGS+=(--rm)
		echo "- Auto remove container on stop"
		shift
		;;
	-n | --name)
		BOXNAME="$2"
		shift 2
		;;
	esac
done

setup_display() {
	if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}" ]; then
		echo "- Using Wayland"
		EXTRA_ARGS+=(
			-e "WAYLAND_DISPLAY=${WAYLAND_DISPLAY}"
			-v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY"
		)
		return 0
	fi

	echo "- Display server not detected. No GUI." >&2
	return 1
}

setup_graphics() {
	EXTRA_ARGS+=(
		--device /dev/dri
		--group-add video
	)
}

setup_audio() {
	local pulse_socket="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/pulse/native"

	if [ -S "${pulse_socket}" ]; then
		echo "- Activating sound pass-through..."
		EXTRA_ARGS+=(
			-v "${pulse_socket}:/tmp/pulse-socket:ro"
			-e "PULSE_SERVER=unix:/tmp/pulse-socket"
		)
		return 0
	fi

	echo "- No active audio socket detected at ${pulse_socket}. Audio disabled."
	return 1
}

main() {
	local default_args
	default_args=(
		-d
		--userns=keep-id
		--name "$BOXNAME"
		-v $HOME/.osboxes/work-home:/root:Z
	)

	setup_display
	setup_graphics
	setup_audio

	podman run \
		${default_args[@]} \
		${EXTRA_ARGS[@]} \
		"$IMGNAME"
}

main
