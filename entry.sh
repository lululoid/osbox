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
	fi

	if [ -n "${DISPLAY:-}" ]; then
		local XAUTH="${XAUTHORITY:-${HOME}/.Xauthority}"
		EXTRA_ARGS+=(
			-e "DISPLAY=${DISPLAY}"
			-v "/tmp/.X11-unix:/tmp/.X11-unix:ro"
		)
		echo "- Display ${DISPLAY}"
		if [ -f "${XAUTH}" ]; then
			EXTRA_ARGS+=(
				-e "XAUTHORITY=/run/user/$(id -u)/.Xauthority"
				-v "${XAUTH}:/run/user/$(id -u)/.Xauthority:ro"
			)
		fi
	fi

	if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ]; then
		echo "- Display server not detected. No GUI." >&2
		return 1
	fi
}

setup_graphics() {
	EXTRA_ARGS+=(
		--device /dev/dri
		--group-add video
	)
}

setup_audio() {
	local uid runtime_dir pulse_socket pipewire_socket
	uid="$(id -u)"
	runtime_dir="${XDG_RUNTIME_DIR:-/run/user/${uid}}"
	pulse_socket="${runtime_dir}/pulse/native"
	pipewire_socket="${runtime_dir}/pipewire-0"

	if [ -S "${pulse_socket}" ]; then
		echo "- Activating PulseAudio pass-through..."
		EXTRA_ARGS+=(
			-v "${pulse_socket}:/tmp/pulse-socket:ro"
			-e "PULSE_SERVER=unix:/tmp/pulse-socket"
		)
		return 0
	fi

	if [ -S "${pipewire_socket}" ]; then
		echo "- Activating PipeWire pass-through..."
		EXTRA_ARGS+=(
			-v "${pipewire_socket}:/tmp/pipewire-0:ro"
			-e "PIPEWIRE_SOCKET=unix:/tmp/pipewire-0"
		)
		# PipeWire with PulseAudio compat may expose a pulse socket too
		if [ -S "${pulse_socket}" ]; then
			EXTRA_ARGS+=(
				-v "${pulse_socket}:/tmp/pulse-socket:ro"
				-e "PULSE_SERVER=unix:/tmp/pulse-socket"
			)
		fi
		return 0
	fi

	echo "- No active audio socket detected at ${pulse_socket} or ${pipewire_socket}. Audio disabled."
	return 1
}

main() {
	local default_args
	default_args=(
		-d
		--userns=keep-id
		--name "$BOXNAME"
		--security-opt label=type:container_runtime_t
		-v $HOME/.osboxes/work-home:/home/${USER}:Z
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
