FROM centos:6

#####################################
# Package updates and installations #
#####################################

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

####################
# CBRAIN code copy #
####################

COPY . /home/cbrain/cbrain
USER root
RUN chown cbrain:cbrain -R /home/cbrain/cbrain
USER cbrain

################################
# Rails application bundling   #
################################

RUN cd ${HOME}/cbrain/BrainPortal              && \
    bundle install                             && \
    cd `bundle show sys-proctable`             && \
    rake install

RUN cd ${HOME}/cbrain/Bourreau       && \
    bundle install && \
    cd `bundle show sys-proctable` && \
    rake install

#########################
# Plugin installation   #
#########################

RUN cd ${HOME}/cbrain/BrainPortal    && \
    rake cbrain:plugins:install:all

RUN cd ${HOME}/cbrain/Bourreau    && \
    rake cbrain:plugins:install:plugins
    
EXPOSE 3000

ENTRYPOINT ["/home/cbrain/cbrain/Docker/run.sh"]
CMD ["portal","development","3000"]
VOLUME /cbrain_data_cache /cbrain_task_dirs