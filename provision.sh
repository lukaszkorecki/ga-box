#!/usr/bin/env bash

set -e

log() {
  logger -s -t PROVISIONER -- "$*"
}

Quiet() {
  log "> $*"
  $* > /dev/null
}

# get all required packages

Quiet apt-get update -q
Quiet apt-get -y -q install git-core  \
  python-software-properties \
  libpq-dev \
  build-essential \
  unzip \
  libsqlite3-dev \
  poppler-utils \
  libcurl4-openssl-dev \
  libsqlite3-dev \
  nfs-server


# add brightbox ppa

Quiet apt-add-repository ppa:brightbox/ruby-ng

# install latest ruby

Quiet apt-get update -q

Quiet apt-get -y -q install ruby2.1  ruby2.1-dev

Quiet update-alternatives --set ruby /usr/bin/ruby2.1

gem install bundler pry rails --no-rdoc --no-ri

# some cleanup
apt-get autoremove -y

# nfs server

if [[ -e /etc/init.d/iptables-persistent ]] ; then
  /etc/init.d/iptables-persistent flush
fi

echo "/home/vagrant *(rw,sync,all_squash,anonuid=1000,insecure,no_subtree_check)" > /etc/exports
exportfs -a
/etc/init.d/nfs-kernel-server restart
