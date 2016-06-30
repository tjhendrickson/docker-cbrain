#!/bin/bash -e

source /home/cbrain/.bashrc

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

if [ -z "${PORTAL_PORT}" ] || [ -z "${PORTAL_HOST}" ]
then
    echo "usage: bourreau.sh with the following environment variables:"
    echo
    echo "PORTAL_HOST: the host where the CBRAIN portal is started."
    echo
    echo "PORTAL_PORT: the port where the CBRAIN portal is started."
    exit 1
fi

# Edits Bourreau configuration file from template
dockerize -template $HOME/cbrain/Docker/templates/config_bourreau.rb.TEMPLATE:$HOME/cbrain/Bourreau/config/initializers/config_bourreau.rb || die "Cannot edit Bourreau configuration file"

install_plugins_bourreau

# Wait for the portal to start so that we are sure that the ssh keys
# are already created
dockerize -wait tcp://${PORTAL_HOST}:${PORTAL_PORT} -timeout 120s || die "Cannot wait for ${PORTAL_HOST}:${PORTAL_PORT} to be up or timeout was reached"

# Automatic exchange of SSH keys
test -f /home/cbrain/.portal_ssh/id_cbrain_portal.pub || die "Cannot find portal public key in /home/cbrain/.portal_ssh/id_cbrain_portal.pub"

cat /home/cbrain/.portal_ssh/id_cbrain_portal.pub >> /home/cbrain/.ssh/authorized_keys
chmod 600 /home/cbrain/.ssh/authorized_keys

