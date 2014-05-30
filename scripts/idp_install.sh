#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# install a Ubuntu LTS server with no specific additional package
# and configure networking so that IP address, hostname and FQDN are correct

# install puppet
cd /tmp
wget -N https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
apt-get install puppet puppetmaster

# install other prerequisite packages
apt-get install python-jinja2
apt-get install git

# clone repository from Git
cd /opt
git clone https://github.com/ConsortiumGARR/Puppet-GARRShibbolethIdP
cd Puppet-GarrShibbolethIdP
git submodule init
git submodule update

# install modules in puppet
cd /etc/puppet/modules
for i in /opt/Puppet-GarrShibbolethIdP/puppetlabs/*; do ln -s $i; done
for i in /opt/Puppet-GarrShibbolethIdP/garr-common/garr/*; do ln -s $i; done
for i in /opt/Puppet-GarrShibbolethIdP/garr/*; do ln -s $i; done

# execute scripts for initializing puppet master
cd /opt/Puppet-GarrShibbolethIdP/scripts
./prepare_puppetmaster.sh
./generate_sitepp.py

# restart puppet master
service puppetmaster restart

# run puppet installation
puppet agent --server `hostname -f` --pluginsync --test