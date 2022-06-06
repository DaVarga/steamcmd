#!/bin/bash

# Set original entrypoint
set -- tini -- start.sh ${@}

# Fix file and directory permissions if run as root
if [ $(id -u) -eq 0 ]; then

    # Configure time zone for runtime
    echo "Setting time zone to: ${TIME_ZONE}"
    ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

    # Set steamcmd user GID and UID
    groupmod -g ${STEAMCMD_GID} steamcmd
    usermod -u ${STEAMCMD_UID} steamcmd

    # Change ownership of steamcmd dumps folder to new steamcmd GID and UID
    mkdir -p /tmp/dumps
    chown -R steamcmd:steamcmd /tmp/dumps

    # Change ownership of steamcmd server folder to new steamcmd GID and UID
    chown -R steamcmd:steamcmd ${STEAMCMD_SERVER_HOME}

    # Call to gosu to drop from root user to steamcmd user
    # when running original entrypoint
    set -- gosu steamcmd $@
fi

exec ${@}
