#!/bin/bash

# exit script if return code != 0
set -e

# send stdout and stderr to supervisor log file (to capture output from this script)
exec 3>&1 4>&2 1>>/config/supervisord.log 2>&1

cat << "EOF"
Created by...
___.   .__       .__                   
\_ |__ |__| ____ |  |__   ____ ___  ___
 | __ \|  |/    \|  |  \_/ __ \\  \/  /
 | \_\ \  |   |  \   Y  \  ___/ >    < 
 |___  /__|___|  /___|  /\___  >__/\_ \
     \/        \/     \/     \/      \/
   https://hub.docker.com/u/binhex/

EOF

echo "[info] System information $(uname -a)"

export PUID=$(echo "${PUID}" | sed -e 's/^[ \t]*//')
if [[ ! -z "${PUID}" ]]; then
	echo "[info] PUID defined as '${PUID}'"
else
	echo "[warn] PUID not defined (via -e PUID), defaulting to '99'"
	export PUID="99"
fi

# set user nobody to specified user id (non unique)
usermod -o -u "${PUID}" nobody &>/dev/null

export PGID=$(echo "${PGID}" | sed -e 's/^[ \t]*//')
if [[ ! -z "${PGID}" ]]; then
	echo "[info] PGID defined as '${PGID}'"
else
	echo "[warn] PGID not defined (via -e PGID), defaulting to '100'"
	export PGID="100"
fi

# set group nobody to specified group id (non unique)
groupmod -o -g "${PGID}" nobody &>/dev/null

# set umask to specified value if defined
if [[ ! -z "${UMASK}" ]]; then
	echo "[info] UMASK defined as '${UMASK}'"
	sed -i -e "s~umask.*~umask = ${UMASK}~g" /etc/supervisor.d/*.ini
else
	echo "[warn] UMASK not defined (via -e UMASK), defaulting to '000'"
	sed -i -e "s~umask.*~umask = 000~g" /etc/supervisor.d/*.ini
fi

# check for presence of perms file, if it exists then skip setting
# permissions, otherwise recursively set on volume mappings for host
if [[ ! -f "/config/perms.txt" ]]; then

	echo "[info] Setting permissions recursively on volume mappings..."

	if [[ -d "/data" ]]; then
		volumes=( "/config" "/data" )
	else
		volumes=( "/config" )
	fi

	set +e
	chown -R "${PUID}":"${PGID}" "${volumes[@]}"
	exit_code_chown=$?
	chmod -R 775 "${volumes[@]}"
	exit_code_chmod=$?
	set -e

	if (( ${exit_code_chown} != 0 || ${exit_code_chmod} != 0 )); then
		echo "[warn] Unable to chown/chmod ${volumes}, assuming SMB mountpoint"
	fi

	echo "This file prevents permissions from being applied/re-applied to /config, if you want to reset permissions then please delete this file and restart the container." > /config/perms.txt

else

	echo "[info] Permissions already set for volume mappings"

fi

# ENVVARS_PLACEHOLDER

# PERMISSIONS_PLACEHOLDER

# restore stdout/stderr (to prevent duplicate logging from supervisor)
exec 1>&3 2>&4

echo "[info] Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisord.conf -n
