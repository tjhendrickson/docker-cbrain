FROM centos:6

#####################################
# Package updates and installations #
#####################################

# Note: keep the package list alphabetically
#       ordered to facilitate parsing

RUN yum update -y  && \
    yum install -y \
      autoconf \
      automake \
      bison \
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
      mysql-devel \
      openssl-devel \
      patch \
      readline-devel \
      sqlite-devel \
      zlib-devel \
      wget && \
   useradd cbrain

##########################
# Dockerize installation #
##########################

# Dockerize is used in run.sh to edit template configuration files and
# to wait for the DB to be started before starting the portal

ENV DOCKERIZE_VERSION v0.2.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz 

#####################
# Ruby installation #
#####################

USER cbrain

ENV RUBY_VERSION=2.2.0
ENV PATH=$PATH:/home/cbrain/.rvm/rubies/ruby-${RUBY_VERSION}/bin      

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    cd $HOME && \
    curl -sSL https://get.rvm.io | bash -s stable && \
    /bin/bash -c "source $HOME/.rvm/scripts/rvm; rvm install $RUBY_VERSION; rvm --default $RUBY_VERSION" && \
    gem install bundler
