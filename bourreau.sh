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

# Edits Bourreau configuration file from template
dockerize -template $HOME/cbrain/Docker/templates/config_bourreau.rb.TEMPLATE:$HOME/cbrain/Bourreau/config/initializers/config_bourreau.rb || die "Cannot edit Bourreau configuration file"

install_plugins_bourreau
