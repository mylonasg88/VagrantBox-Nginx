#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export COMPOSER_ALLOW_SUPERUSER=1
export ZEPHIRDIR=/usr/share/zephir
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#
# Add Swap
#
dd if=/dev/zero of=/swapspace bs=1M count=4000
mkswap /swapspace
swapon /swapspace
echo "/swapspace none swap defaults 0 0" >> /etc/fstab

echo nameserver 8.8.8.8 > /etc/resolv.conf
echo nameserver 8.8.4.4 > /etc/resolv.conf

#
# Add PHP and PostgreSQL repositories
#
LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php
touch /etc/apt/sources.list.d/pgdg.list
echo -e "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | tee -a /etc/apt/sources.list.d/pgdg.list &>/dev/null
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Cleanup package manager
apt-get clean -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

apt-get update -qq
apt-get upgrade -y
apt-get install -y build-essential software-properties-common python-software-properties

#
# Setup locales
#
echo -e "LC_CTYPE=en_US.UTF-8\nLC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8" | tee -a /etc/environment &>/dev/null
locale-gen en_US en_US.UTF-8
dpkg-reconfigure locales

wget -qO- https://deb.nodesource.com/setup_6.x | sudo bash -
sudo apt-get install nodejs

#
# Base system
#
apt-get install -yq --no-install-suggests --no-install-recommends \
  mysql-server-5.6 \
  mysql-client-5.6 \
  memcached \
  curl \
  htop \
  git \
  dos2unix \
  unzip \
  vim \
  mc \
  grc \
  gcc \
  make \
  re2c \
  libpcre3 \
  libpcre3-dev \
  lsb-core \
  autoconf \

#
# Base PHP
#
apt-get install -yq --no-install-suggests --no-install-recommends \
  php5.6 \
  php5.6-apcu \
  php5.6-bcmath \
  php5.6-bz2 \
  php5.6-cli \
  php5.6-common \
  php5.6-curl \
  php5.6-dba \
  php5.6-dev \
  php5.6-gd \
  php5.6-gearman \
  php5.6-gettext \
  php5.6-gmp \
  php5.6-imagick \
  php5.6-imap \
  php5.6-intl \
  php5.6-json \
  php5.6-mbstring \
  php5.6-memcached \
  php5.6-memcache \
  php5.6-mcrypt \
  php5.6-mongo \
  php5.6-mongodb \
  php5.6-mysql \
  php-pear \
  php5.6-odbc \
  php5.6-ps \
  php5.6-pspell \
  php5.6-redis \
  php5.6-readline \
  php5.6-recode \
  php5.6-soap \
  php5.6-sqlite3 \
  php5.6-tidy \
  php5.6-xdebug \
  php5.6-xmlrpc \
  php5.6-xsl \
  php5.6-zip
  #php5.6-pgsql \

echo "apc.enable_cli = 1" >> /etc/php/5.6/mods-available/apcu.ini

apt-get install -yq --no-install-suggests --no-install-recommends expect

#
# Update PECL channel
#
pecl channel-update pecl.php.net
phpdismod xdebug redis

#
# Tune Up MySQL
#
cp /etc/mysql/my.cnf /etc/mysql/my.bkup.cnf
sed -i 's/bind-address/bind-address = 0.0.0.0#/' /etc/mysql/my.cnf
#mysql -u root -Bse "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES;"

#echo 'create database forum_dev;' | mysql --user=vagrant --password=vagrant
#mysql --user=vagrant --password=vagrant forum_dev < /var/www/forum/VagrantFiles/forum_dev.sql

#
# Composer for PHP
#
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#
# Tune UP PHP
#
phpenmod -v 5.6 -s ALL yaml mcrypt intl curl libsodium phalcon soap redis xdebug

cd ~

#
# Setup Xdebug
#
echo 'xdebug.remote_enable = on
    xdebug.remote_connect_back = on
    xdebug.idekey = "vagrant"' >> /etc/php/5.6/mods-available/xdebug.ini

#
# Install Nginx
#
sudo apt-get install -yq --no-install-suggests --no-install-recommends \
    nginx

sudo ln -s /var/www/devbox/VagrantFiles/nginx-devbox.dev.conf /etc/nginx/sites-enabled/
sudo service nginx restart

############################################################
# Install ZSH
#
apt-get install -y -q zsh

# Clone oh-my-zsh
if [ ! -d ~vagrant/.oh-my-zsh ]; then
  git clone https://github.com/robbyrussell/oh-my-zsh.git ~vagrant/.oh-my-zsh
fi

# Create a new zsh configuration from the provided template
cp ~vagrant/.oh-my-zsh/templates/zshrc.zsh-template ~vagrant/.zshrc

# Change ownership of .zshrc
chown vagrant: ~vagrant/.zshrc

# Customize theme
sed -i -e 's/ZSH_THEME=".*"/ZSH_THEME="ys"/' ~vagrant/.zshrc

# add aliases
sed -i -e 's/# Example aliases/source ~\/.bash_aliases/gi' ~vagrant/.zshrc

# Set zsh as default shell
chsh -s /bin/zsh vagrant

#
##
############################################################

#
#  Cleanup
#
apt-get autoremove -y
apt-get autoclean -y
