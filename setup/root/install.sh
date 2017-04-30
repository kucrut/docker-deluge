#!/bin/bash

# exit script if return code != 0
set -e

# container perms
####

# create file with contets of here doc
cat <<'EOF' > /tmp/permissions_heredoc
echo "[info] Setting permissions on files/folders inside container..."

# create path to store deluge python eggs
mkdir -p /home/nobody/.cache/Python-Eggs

chown -R "${PUID}":"${PGID}" /usr/bin/deluged /usr/bin/deluge-web /home/nobody
chmod -R 775 /usr/bin/deluged /usr/bin/deluge-web /home/nobody

# remove permissions for group and other from the Python-Eggs folder
chmod -R 700 /home/nobody/.cache/Python-Eggs

EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /root/init.sh
rm /tmp/permissions_heredoc
