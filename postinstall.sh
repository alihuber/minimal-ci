#!/bin/bash

RUBY_VERSION='1.9.3-p392'
USER='vagrant'

# Install packages necessary for Ruby
echo 'VAGRANT INSTALL: install packages needed for setup and building'
sudo apt-get update
sudo apt-get install curl git-core patch build-essential bison zlib1g-dev libssl-dev libxml2-dev libxml2-dev sqlite3 libsqlite3-dev autotools-dev libxslt1-dev libyaml-0-2 libyaml-dev autoconf automake libreadline6-dev libyaml-dev libtool libgdbm-dev libncurses5-dev pkg-config libffi-dev -y


# Install rbenv
# =============
# echo 'VAGRANT INSTALL: install rbenv'
# git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv
# Add rbenv to the path:
# echo '# rbenv setup' > /etc/profile.d/rbenv.sh
# echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
# echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
# echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
# chmod +x /etc/profile.d/rbenv.sh
# source /etc/profile.d/rbenv.sh
# Install ruby-build:
# pushd /tmp
# git clone git://github.com/sstephenson/ruby-build.git
# cd ruby-build
# ./install.sh
# cd ..
# rm -rf ruby-build*
# popd
# Install Ruby
# echo 'VAGRANT INSTALL: install Ruby'
# rbenv install $RUBY_VERSION
# rbenv global $RUBY_VERSION
# Rehash rbenv
# rbenv rehash
# Update RubyGems since rbenv comes with a version of rubygems
# gem update --system


# Install rvm
# ===========
echo 'VAGRANT INSTALL: install rvm'
\curl https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable
useradd -g rvm vagrant
source /etc/profile.d/rvm.sh
echo 'VAGRANT INSTALL: install Ruby'
rvm install $RUBY_VERSION
rvm use 1.9.3 --default



# Disallow ri and rdoc in gems to speed up gem installs
pushd /home/$USER
echo 'gem: --no-ri --no-rdoc' > .gemrc
popd

exit
