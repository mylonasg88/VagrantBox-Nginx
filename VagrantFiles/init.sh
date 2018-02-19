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
#
# Base PHP
#
apt-get install -yq --no-install-suggests --no-install-recommends \
  php-pear \
  php7.1-cli \
  php7.1-cgi \
  php7.1-fpm \
  php7.1 \
  php7.1-apcu \
  php7.1-bcmath \
  php7.1-bz2 \
  php7.1-cli \
  php7.1-common \
  php7.1-curl \
  php7.1-dba \
  php7.1-dev \
  php7.1-gd \
  php7.1-gettext \
  php7.1-gmp \
  php7.1-imagick \
  php7.1-imap \
  php7.1-intl \
  php7.1-json \
  php7.1-mbstring \
  php7.1-memcached \
  php7.1-memcache \
  php7.1-mcrypt \
  php7.1-mongo \
  php7.1-mongodb \
  php7.1-mysql \
  php7.1-odbc \
  php7.1-ps \
  php7.1-pspell \
  php7.1-redis \
  php7.1-readline \
  php7.1-recode \
  php7.1-soap \
  php7.1-sqlite3 \
  php7.1-tidy \
  php7.1-xdebug \
  php7.1-xmlrpc \
  php7.1-xsl \
  php7.1-zip \
  php7.1-pgsql

#echo "apc.enable_cli = 1" >> /etc/php/5.6/mods-available/apcu.ini

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
phpenmod -v 7.1 -s ALL yaml mcrypt intl curl soap redis xdebug

cd ~

#
# Setup Xdebug
#
echo 'xdebug.remote_enable = on
    xdebug.remote_connect_back = on
    xdebug.idekey = "vagrant"' >> /etc/php/7.1/mods-available/xdebug.ini

#
# Install Nginx
#
sudo apt-get install -yq --no-install-suggests --no-install-recommends \
    nginx

sudo ln -s /var/www/devbox/VagrantFiles/nginx-devbox.dev.conf /etc/nginx/sites-enabled/
sudo chmod 777 /var/log/nginx/error.log
sudo service nginx restart

############################################################
# Install ZSH
#
apt-get install -y -q zsh

# Clone oh-my-zsh
if [ ! -d ~vagrant/.oh-my-zsh ]; then
  git clone https://github.com/robbyrussell/oh-my-zsh.git ~vagrant/.oh-my-zsh
fi

# Create a new zsh configuration from the provided template.
cp ~vagrant/.oh-my-zsh/templates/zshrc.zsh-template ~vagrant/.zshrc

# Change ownership of .zshrc
chown vagrant: ~vagrant/.zshrc

# Customize theme
sed -i -e 's/ZSH_THEME=".*"/ZSH_THEME="ys"/' ~vagrant/.zshrc

# add aliases
sed -i -e 's/# Example aliases/source ~\/.bash_aliases/gi' ~vagrant/.zshrc

# Set zsh as default shell
chsh -s /bin/zsh vagrant

# Copy zsh template with Git disabled for speed performance.
cp /var/www/devbox/VagrantFiles/ys.zsh-theme /home/vagrant/.oh-my-zsh/themes

#
##
############################################################

#
#  Cleanup
#
apt-get autoremove -y
apt-get autoclean -y
