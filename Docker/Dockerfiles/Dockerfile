FROM centos:7.4.1708

#####################################
# Package updates and installations #
#####################################

# Note: keep the package list alphabetically
#       ordered to facilitate parsing
RUN yum update -y && \
    yum install -y \
      autoconf \
      automake \
      bison \
      bzip2 \
      gcc-c++ \
      git \
      glibc-devel \
      glibc-headers \
      gpg \
      libffi-devel \
      libmysqlclient-dev \
      libtool \
      libxml2 \
      libxml2-devel \
      libyaml-devel \
      make \
      mysql-devel \
      openssl-devel \
      patch \
      readline-devel \
      ruby \
      sqlite-devel \
      tar \
      wget \
      zlib-devel \
      wget \
      which && \
    yum clean all && \
    useradd cbrain

RUN cd /tmp && \
   wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz -O /tmp/libsodium.tar.gz && \
   tar -xzvf  /tmp/libsodium.tar.gz -C /tmp && \
   cd /tmp/libsodium-1.0.18 && \
   ./configure && \
   make && \
   make check && \
   make install

##########################
# Dockerize installation #
##########################

# Dockerize is used in run.sh to edit template configuration files and
# to wait for the DB to be started before starting the portal
# Dumb-init is an init process that can be used in Docker containers.
# In particular, it takes care of removing zombie processes inside a running Docker container.

ENV DOCKERIZE_VERSION=v0.6.0 \
    DUMB_INIT_VERSION=1.2.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    chmod +x /usr/local/bin/dumb-init

#####################
# Ruby installation #
#####################

USER cbrain

ENV RUBY_VERSION=2.4.1
RUN gpg2 --keyserver hkp://pool.sks-keyservers.net \
	--recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
	 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN cd $HOME && \
    curl -sSL https://rvm.io/mpapis.asc | gpg2 --import - && \
    curl -sSL https://get.rvm.io | bash -s stable && \
    echo source ${HOME}/.profile >> ${HOME}/.bashrc && \
    source /home/cbrain/.bashrc && \
    rvm install $RUBY_VERSION && \
    rvm --default $RUBY_VERSION && \
    echo source "\$(rvm ${RUBY_VERSION} do rvm env --path)" >> ${HOME}/.bashrc && \
    source /home/cbrain/.bashrc && \
    rvm info && \
    gem install bundler
