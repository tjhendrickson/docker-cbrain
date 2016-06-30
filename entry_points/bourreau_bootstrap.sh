#!/bin/bash -e

#####################
# Utility functions #
#####################

# Prints a message and exits with a non-zero code.
function die {
    echo $*
    exit 1
}

# Generate Host keys, if required
function generate_ssh_host_keys {
    local RSA_KEY=/etc/ssh/ssh_host_rsa_key
    local DSA_KEY=/etc/ssh/ssh_host_dsa_key
    local KEYGEN=/usr/bin/ssh-keygen

    if [ ! -s $RSA_KEY ]; then
        echo -n "Generating SSH2 RSA host key: "
        rm -f $RSA_KEY
        if test ! -f $RSA_KEY && $KEYGEN -q -t rsa -f $RSA_KEY -C '' -N '' >&/dev/null; then
            chmod 600 $RSA_KEY
            chmod 644 $RSA_KEY.pub
            if [ -x /sbin/restorecon ]; then
                /sbin/restorecon $RSA_KEY.pub
            fi
        else
            die "RSA key generation failed"
        fi
    fi

    if [ ! -s $DSA_KEY ]; then
        echo -n "Generating SSH2 DSA host key: "
        rm -f $DSA_KEY
        if test ! -f $DSA_KEY && $KEYGEN -q -t dsa -f $DSA_KEY -C '' -N '' >&/dev/null; then
            chmod 600 $DSA_KEY
            chmod 644 $DSA_KEY.pub
            if [ -x /sbin/restorecon ]; then
                /sbin/restorecon $DSA_KEY.pub
            fi
        else
            die $"DSA key generation failed"
        fi
    fi
}

###############
# Main script #
###############

if [ -z "$USERID" ] || [ -z "$GROUPID" ] || [ -z "${PORTAL_PORT}" ] || [ -z "${PORTAL_HOST}" ]
then
    echo "usage: bourreau_bootstrap.sh with the following environment variables"
    echo
    echo "USERID: ID of the user that will run the CBRAIN bourreau."
    echo
    echo "GROUPID: group ID of the user that will run the CBRAIN bourreau."
    echo
    echo "PORTAL_PORT: the port where the CBRAIN portal is started."
    echo
    echo "PORTAL_HOST: the host where the CBRAIN portal is started."
    exit 1
fi

groupmod -g ${GROUPID} cbrain || die "groupmod -g ${GROUPID} cbrain failed"
usermod -u ${USERID} cbrain  || die "usermod -u ${USERID} cbrain" # the files in /home/cbrain are updated automatically
for volume in /home/cbrain/cbrain_data_cache \
                  /home/cbrain/plugins \
                  /home/cbrain/cbrain_task_directories \
                  /home/cbrain/.ssh
do
    echo "chowning ${volume}"
    chown cbrain:cbrain ${volume}
done
generate_ssh_host_keys

# Initialize Bourreau configuration and plugins
su cbrain "/home/cbrain/cbrain/Docker/entry_points/bourreau.sh"

echo "Starting bourreau"
exec /usr/sbin/sshd -D 
