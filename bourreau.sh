#!/bin/bash -e


#####################
# Utility functions #
#####################

# Prints a message and exits with a non-zero code.
function die {
    echo $*
    exit 1
}

# Installs the plugins in the Bourreau.
function install_plugins_bourreau { 
    cd ${HOME}/cbrain/Bourreau          || die "Cannot cd to \
                                           Bourreau directory"
    bundle install                      || die "Cannot bundle install"
    rake cbrain:plugins:install:plugins || die "Cannot install plugins"
}

###############
# Main script #
###############

if [ -z "$USERID" ] || [ -z "$GROUPID" ]
then
    echo "usage: bourreau.sh with the following environment variables"
    echo
    echo "USERID: ID of the user that will run the CBRAIN bourreau."
    echo
    echo "GROUPID: group ID of the user that will run the CBRAIN bourreau."
    exit 1
fi

if [ $UID -eq 0 ]
then
    groupmod -g ${GROUPID} cbrain || die "groupmod -g ${GROUPID} cbrain failed"
    usermod -u ${USERID} cbrain  || die "usermod -u ${USERID} cbrain" # the files in /home/cbrain are updated automatically
    for volume in /home/cbrain/cbrain_data_cache \
                      /home/cbrain/plugins \
                      /home/cbrain/cbrain_task_directories
    do
        echo "chowning ${volume}"
        chown cbrain:cbrain ${volume}
    done
    su cbrain "$0" "$@"
    # Generate Host keys, if required
    if ! ls /etc/ssh/ssh_host_* 1> /dev/null 2>&1; then
      ssh-keygen -A
    fi
    echo "Starting bourreau"
    exec /usr/sbin/sshd -D 
fi

# Edits DB configuration file from template
dockerize -template $HOME/cbrain/Docker/templates/config_bourreau.rb.TEMPLATE:$HOME/cbrain/Bourreau/config/initializers/config_bourreau.rb || die "Cannot edit Bourreau configuration file"

install_plugins_bourreau
