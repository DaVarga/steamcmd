#!/bin/bash

if [[ $(id -u) -ne ${STEAMCMD_UID} ]]; then
    exec gosu steamcmd ${0} $@
fi

source /usr/local/lib/steamcmd/server-common.sh src2

# Define SRC2-specific functions
_setup_csgo_hibernation_hook_attached() {
    ${TMUX_CMD} set-hook -t "${STEAMCMD_SERVER_SESSION_NAME}" -u client-attached
    ${TMUX_CMD} set-hook -t "${STEAMCMD_SERVER_SESSION_NAME}" client-attached 'send-keys "sv_hibernate_when_empty 0" "Enter"'
}


_setup_csgo_hibernation_hook_detached() {
    ${TMUX_CMD} set-hook -t "${STEAMCMD_SERVER_SESSION_NAME}" -u client-detached
    ${TMUX_CMD} set-hook -t "${STEAMCMD_SERVER_SESSION_NAME}" client-detached 'send-keys "sv_hibernate_when_empty 1" "Enter"'
}


_setup_csgo_hibernation_hooks() {
    if _is_attached; then
        ${TMUX_CMD} send-keys -t "${STEAMCMD_SERVER_SESSION_NAME}" "sv_hibernate_when_empty 0" "Enter"
    fi

    _setup_csgo_hibernation_hook_detached
    _setup_csgo_hibernation_hook_attached
}


attach() {
    _attach
}


update() {
    _update
}


run() {
    pre_exit_code=$(_run_pre)

    if ! $pre_exit_code; then
        return $pre_exit_code
    fi

    echo "${MESSAGE_STEAMCMD_SERVER_STARTED}"

    ${TMUX_CMD} send-keys -t "${STEAMCMD_SERVER_SESSION_NAME}" \
        "cd ${STEAMCMD_SERVER_HOME}/game/bin/linuxsteamrt64; \
        ./cs2 -dedicated +map ${STEAMCMD_SERVER_MAP} ${STEAMCMD_SERVER_LAUNCH_PARAMS}" \
        "Enter"

    _run_post

    # _setup_csgo_hibernation_hooks
    
    return 0
}


${@}
