#!/bin/bash

if [ $(id -u) -ne ${STEAMCMD_UID} ]; then
    exec runuser -u steamcmd -- ${0} $@
fi


_is_running() {
    return $(ps cax | grep ${1} > /dev/null)
}


healthy() {
    return $(tmux capture-pane -pt ${STEAMCMD_SERVER_SESSION_NAME} | grep -w "Connection to Steam servers successful." > /dev/null)
}


wait() {
    until ! _is_running srcds; do :; done
    return 0
}


attach() {
    tmux a -t ${STEAMCMD_SERVER_SESSION_NAME}
}


update() {
    if _is_running steamcmd; then
        return 1
    fi

    echo "Updating game server... Use 'server.sh attach' to attach to the SRCDS tmux session."

    tmux send-keys -t ${STEAMCMD_SERVER_SESSION_NAME} "steamcmd \
        +force_install_dir ${STEAMCMD_SERVER_HOME} \
        +login anonymous \
        +app_update ${STEAMCMD_SERVER_APPID} validate \
        +quit; tmux wait-for -S steamcmd-update-finished" "Enter"

    tmux wait-for steamcmd-update-finished
    echo "Finished."

    return 0
}


run() {
    if _is_running steamcmd; then
        echo "SteamCMD is currently updating. Use 'server.sh attach' to attach to the SRCDS tmux session."
        return 1
    fi

    if _is_running srcds; then
        echo "SRCDS is currently running. Use 'server.sh attach' to attach to the SRCDS tmux session."
        return 2
    fi

    steamcmd_cfg_dir=${STEAMCMD_SERVER_HOME}/${STEAMCMD_SERVER_GAME}/cfg

    # Copy server.cfg file to the server cfg folder if it doesn't exist yet
    if [ ! -f ${steamcmd_cfg_dir}/server.cfg ]; then
        cp /etc/steamcmd/srcds/cfg/server.cfg ${steamcmd_cfg_dir}/server.cfg
    fi

    # Prepare tickrate_enabler.cfg file in the server cfg folder if it doesn't exist yet
    if [ ! -f ${steamcmd_cfg_dir}/tickrate_enabler.cfg ]; then
        echo "sv_minupdaterate ${STEAMCMD_SERVER_TICKRATE}" > ${steamcmd_cfg_dir}/tickrate_enabler.cfg
        echo "sv_mincmdrate ${STEAMCMD_SERVER_TICKRATE}" >> ${steamcmd_cfg_dir}/tickrate_enabler.cfg
        echo "sv_minrate ${STEAMCMD_SERVER_MINRATE}" >> ${steamcmd_cfg_dir}/tickrate_enabler.cfg
        echo "sv_maxrate ${STEAMCMD_SERVER_MAXRATE}" >> ${steamcmd_cfg_dir}/tickrate_enabler.cfg
        echo "fps_max ${STEAMCMD_SERVER_FPSMAX}" >> ${steamcmd_cfg_dir}/tickrate_enabler.cfg
    fi

    echo "Starting SRCDS in tmux session..."

    tmux send-keys -t ${STEAMCMD_SERVER_SESSION_NAME} "cd ${STEAMCMD_SERVER_HOME}; bash ./srcds_run \
        -console \
        -game ${STEAMCMD_SERVER_GAME} \
        +ip 0.0.0.0 \
        -port ${STEAMCMD_SERVER_PORT} \
        +maxplayers ${STEAMCMD_SERVER_MAXPLAYERS} \
        +map ${STEAMCMD_SERVER_MAP} \
        -tickrate ${STEAMCMD_SERVER_TICKRATE} \
        -threads ${STEAMCMD_SERVER_THREADS} \
        -nodev" "Enter"

    until healthy; do : done

    echo "Successfully started SRCDS in tmux session. Use 'server.sh attach' to attach to it."
    return 0
}


${@}
