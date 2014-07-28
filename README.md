Puppet modules to install Shibboleth IdP on linux
=================================================

This project contains puppet modules for different pieces of software, in particular it is intended to provide the required installation steps for Internet2 implementations of Shibboleth IdP.
The module has been developed and tested on Debian (Squeeze and Wheezy) and on Ubuntu (12.04 LTS) Linux systems.

Configuration of the Puppet Master
==================================
The modules developed can be installed on a Puppet Agent running Puppet >= 3.3.0.

The steps to have a Puppet Master installed correctly are:

* Install Ubuntu 12.04 LTS on the target machine, from the installation parameters, choose ONLY ***standard system utilities*** and ***ssh server*** to minimize the number of packages to be installed on the targed machine.

* Configure the network and the name resolution so that the machine reachable with its FQDN (as returned by `hostname -f`) from the Puppet Agents.

* Install last version of puppet by executing:
  * On Debian Squeeze:
      * `wget http://apt.puppetlabs.com/puppetlabs-release-squeeze.deb`
      * `dpkg -i puppetlabs-release-squeeze.deb`
      * `apt-get update`
      * `apt-get install puppetmaster ruby`
      * `apt-get dist-upgrade`

  * On Debian Wheezy:
      * `wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb`
      * `dpkg -i puppetlabs-release-wheezy.deb`
      * `apt-get update`
      * `apt-get install puppetmaster ruby`
      * `apt-get dist-upgrade`

  * On Ubuntu 12.04 LTS:
      * `wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb`
      * `dpkg -i puppetlabs-release-precise.deb`
      * `apt-get update`
      * `apt-get install puppetmaster ruby`
      * `apt-get dist-upgrade`
* Change `/etc/puppet/puppet.conf` by adding the following lines after `[master]`:
   ```
   [master]
   dns_alt_names = <your_puppet_master_hostname>
   manifest = $confdir/manifests/site.pp
   modulepath = $confdir/modules
   reports = store,tagmail

   ```

* Download from Github into you prefer directory the Puppet-GARRShibbolethIdP code and update submodules.
  In this README we download it into a new directory under `/opt`:
  ```
  cd /opt
  git clone https://github.com/ConsortiumGARR/Puppet-GARRShibbolethIdP
  cd Puppet-GARRShibbolethIdP
  git submodule init
  git submodule update
  ```

* Move or Link all modules from the proper folders of this GitHub project to `/etc/puppet/modules`:
  ```
  cd /etc/puppet/modules
  for i in /opt/Puppet-GARRShibbolethIdP/puppetlabs/*; do ln -s $i; done
  for i in /opt/Puppet-GARRShibbolethIdP/garr-common/garr/*; do ln -s $i; done
  for i in /opt/Puppet-GARRShibbolethIdP/garr/*; do ln -s $i; done
  ```

* Create a new empty file called `/etc/puppet/manifests/site.pp` and a new directory called `/etc/puppet/manifests/nodes`.

* Move on "scripts" directory and execute, in this order, the scripts `prepare_puppetmaster.sh` and `generate_sitepp.py` .

* Restart puppetmaster daemon with `service puppetmaster restart`.

### OPTIONAL: Monitoring with Nagios3

* Install Nagios Server and NRPE Plugin:
  `apt-get install nagios3 nagios-nrpe-plugin`

* Move all CFG files from `monitoring/nagios/config.d/` to `/etc/nagios3/conf.d/`
  ```
  cd /etc/nagios3/conf.d ; ln -s /data/Puppet-Shibboleth/monitoring/nagios/config.d/*.cfg .
  ```

* Move all CFG files from `monitoring/nagios/commands/` to `/etc/nagios-plugins/config/`
  ```
  cd /etc/nagios-plugins/config ; ln -s /data/Puppet-Shibboleth/monitoring/nagios/commands/*.cfg .
  ```

* Remember to change the `garr_hosts.cfg` files with the hostname, and IP Address, of the Puppet Agent.

* Remember to modify the file `check_nrpe.cfg` like this:
    ```
    define command {
      command_name  check_nrpe_1arg
      command_line  /usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -t 600 -c $ARG1$
    }
    ```

* Remember to modify the `--authorization` field of `check_phpldapadmin.cfg` file with the right credentials.

* In the end `service nagios3 restart`


Configuration of the Puppet Agent
=================================

* Install Ubuntu 12.04 LTS on the target machine:
from the installation parameters, choose ONLY **standard system utilities** and **ssh server** to minimize the number of packages to be installed on the targed machine.

* Configure the network and the name resolution so that the machine reachable with its FQDN (as returned by `hostname -f`) from the Puppet Master.

* Install last version of puppet by executing:
  * On Debian Squeeze:
      * `wget http://apt.puppetlabs.com/puppetlabs-release-squeeze.deb`
      * `dpkg -i puppetlabs-release-squeeze.deb`
      * `apt-get update`
      * `apt-get install puppet ruby`
      * `apt-get dist-upgrade`

  * On Debian Wheezy:
      * `wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb`
      * `dpkg -i puppetlabs-release-wheezy.deb`
      * `apt-get update`
      * `apt-get install puppet ruby`
      * `apt-get dist-upgrade`

  * On Ubuntu 12.04 LTS:
      * `wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb`
      * `dpkg -i dpkg -i puppetlabs-release-precise.deb`
      * `apt-get update`
      * `apt-get install puppet ruby`
      * `apt-get dist-upgrade`

* Install Augeas 0.10.0:  
  * On Debian Squeeze:
      * Add `deb http://backports.debian.org/debian-backports squeeze-backports main` to `/etc/apt/source.list` file.
      * Run `apt-get update` and then `apt-get -t squeeze-backports install augeas-lenses augeas-tools libaugeas0`

  * On Debian Wheezy:
      * Nothing because will be installed by Puppet.

  * On Ubuntu 12.04 LTS:
      * Run `apt-get install augeas-tools`.

* Change `/etc/puppet/puppet.conf` by adding the following lines at the end of file:
   ```
   [agent]
   server = <your_puppet_master_fqdn>
   report = true
   pluginsync = true
   runinterval = 1800

   ```

* Modify the file /etc/default/puppet by setting `START=yes` and run puppet service with `service puppet start`.

Puppet installation execution
=============================

Connection the Puppet Agents to Puppet Master
---------------------------------------------

* After running the puppet service on each Puppet Agent, on the Puppet Master, execute this command to sign all SSH Certificate of the Puppet Agents necessary to establish their connection with Puppet Master:  
`puppet cert sign --all`

* Now, if you try to run `puppet agent --test` on each Puppet Agent, you can see if the connection is established or not with the Puppet Master.

Configuration of the Puppet Master to install an Identity Provider Shibboleth on a Puppet Agent
-----------------------------------------------------------------------------------------------

1. Execute the script `prepare_puppetmaster.sh`, after have been modified his **PUPPET_USER** and **PUPPET_SERVER** variables, to generate the mandatory configurations files for your Puppet Agent (or Puppet Agents):
  * the public/private keypair for the certificates to be used for HTTPs and for the IdP metadata;  
  * the TOU HTML file which will be presented to the user when the uApprove screen will be shown; this is mandatory only for those IdP who install uApprove software;  
  * a set of style customization for the user login page that includes:
  * a couple of images containing the Italian and English version of the logo (they may also be equal) with the following sizes: width="32px" height="32px".  
  * a couple of images containing the Italian and English version of the logo (they may also be equal) with the following sizes: width="160px" height="120px".  
  * a CSS file.
<br>
<br>
2. Execute the script `generate_sitepp.py` to generate the mandatory `site.pp` file for your Puppet Agent.  
This file permits the configuration of the IdP instance as for the example `site.pp` provided.

Tests
=====
The modules have been developed for Debian (version Squeeze, Wheezy and Ubuntu 12:04 LTS) and have been tested on an environment using the Debian Squeeze, the Debian Wheezy and the Ubuntu 12.04 LTS versions of Linux.

On the configured Puppet Agent restart the puppet service or run `puppet angent --test` and check that the puppet configuration works properly.


Examples
========

Shibboleth IdP
--------------
To create a machine with the Internet2 implementation of a Shibboleth IdP the following actions
are requested. An example of ``site.pp`` is provided in the homonymous file in this repository.
Below an example configuration that should be put into the site.pp file on the Puppet Master:

```
node '<YOUR_IDP_FQDN>' {
  idpfirewall::firewall { "${hostname}-firewall":
      iptables_enable_network => undef,
  }

  $hostfqdn                = '<YOUR.PRIVATE.NETWORK.IP.ADDRESS>'
  $keystorepassword        = 'puppetpassword'
  $mailto                  = 'admin.idp@mib.garr.it'
  $nagiosserver            = '10.0.0.165'

  shib2common::instance { "${hostname}-common":
    install_apache          => true,
    install_tomcat          => true,
    configure_admin         => true,
    tomcat_admin_password   => 'adminpassword',
    tomcat_manager_password => 'managerpassword',
    hostfqdn                => $hostfqdn,
    keystorepassword        => $keystorepassword,
    mailto                  => $mailto,
    nagiosserver            => $nagiosserver,
  }

  shib2idp::instance { "${hostname}-idp":
    metadata_information    => {
      'en'                => {
        'orgDisplayName'         => 'Test IdP for IdP in the cloud project',
        'communityDesc'          => 'GARR Research&amp;Development',
        'orgUrl'                 => 'http://www.garr.it/',
        'privacyPage'            => 'http://www.garr.it/',
        'nameOrg'                => 'Consortium GARR',
        'idpInfoUrl'             => 'https://<YOUR_IDP_FQDN>/idp/info.html',
        'url_LogoOrg-32x32'      => 'https://<YOUR_IDP_FQDN>/idp/images/logoEnte-32x32_en.png',
        'url_LogoOrg-160x120'    => 'https://<YOUR_IDP_FQDN>/idp/images/logoEnte-160x120_en.png',
      },
      'it'                => {
        'orgDisplayName'         => 'Test IdP for IdP in the cloud project',
        'communityDesc'          => 'GARR Research&amp;Development',
        'orgUrl'                 => 'http://www.garr.it/',
        'privacyPage'            => 'http://www.garr.it/',
        'nameOrg'                => 'Consortium GARR',
        'idpInfoUrl'             => 'https://<YOUR_IDP_FQDN>/idp/info.html',
        'url_LogoOrg-32x32'      => 'https://<YOUR_IDP_FQDN>/idp/images/logoEnte-32x32_it.png',
        'url_LogoOrg-160x120'    => 'https://<YOUR_IDP_FQDN>/idp/images/logoEnte-160x120_it.png',
      },
      'technicalEmail'             => 'mailto:support@garr.it',
      'technicalIDPadminGivenName' => 'GivenName',
      'technicalIDPadminSurName'   => 'SurName',
      'technicalIDPadminTelephone' => '0200000000',
      'registrationInstant'        => '2013-06-27T12:00:00Z',
    },
    idpfqdn                      => $hostfqdn,
    keystorepassword             => $keystorepassword,
    mailto                       => $mailto,
    shibbolethversion            => '2.4.0',
    install_uapprove             => true,
    install_ldap                 => true,
    domain_name                  => 'mib.garr.it',
    basedn                       => 'dc=mib,dc=garr,dc=it',
    rootdn                       => 'cn=admin',
    rootpw                       => 'ldappassword',
    rootldappw                   => 'ldappassword',
    ldap_host                    => undef,
    ldap_use_ssl                 => undef,
    ldap_use_tls                 => undef,
    logserver                    => '10.0.0.165',
    nagiosserver                 => $nagiosserver,
    collectdserver               => '10.0.0.165',
    sambadomain                  => 'IDP-IN-THE-CLOUD',
    test_federation              => true,
    custom_styles                => true,
    first_install                => true,
    phpldap_easy_insert          => true,
    uapprove_version             => '2.5.0',
  }
}
```

The configuration of the IdP begins with an optional configuration of iptables on the agent machine.
The iptables class permits to configure a software firewall on the Puppet agent machine using iptables.
This class ensures that the iptables package is installed on the system and then configures
some rules to filter traffic.

The configuration pushed on each Puppet agent is a configuration which closes all ports except
for ICMP traffic, port 80, 443, 8080 and 8443 (used by Tomcat and so the IdP to work properly)
and port 22 for ssh.
Port 22, in particular, can be configured to be open only on certain networks, specified with
the $iptables_enable_network param to this class.

The iptables class has the following parameters:
 * `$iptables_enable_network` => The network on which ssh should be accessible.
   If set to '192.168.0.0/24', for example, the ssh port will be accessible only by hosts
   with IP ranging from 192.168.0.1 to 192.168.0.254.
   If not set (or set to '') ssh port will be accessible by every network and every host.

Then the example provided install the common module developed by GARR for all Puppet projects related to Shibboleth.
In this module the parameter that can be specified are:

 * `install_apache`: a flag indicating whether to intall Apache httpd web server. Has to be true for Shibboleth IdP.
 * `install_tomcat`: a flag indicating whether to intall Tomcat applicationserver. Has to be true for Shibboleth IdP.
 * `configure_admin`: this param permits to specify if the Tomcat administration interface has to be
   installed on the Tomcat instance or not. If set to true the administration interface is installed and will be
   accessible on the port 8080 of the Puppet agent machine.
 * `tomcat_admin_password`: If the Tomcat administration interface is going to be installed this parameter
   permits to specify the password for the 'admin' user used by tomcat to access the administration interface. 
 * `tomcat_manager_password`: If the Tomcat administration interface is going to be installed this parameter
   permits to specify the password for the 'manager' user used by tomcat to access the administration interface.
 * `hostfqdn`: the fully qualified hostname for the IdP to be installed.
 * `keystorepassword`: this parameter permits to specify the keystore password used to protect the keystore file
   on the IdP server.
 * `mailto`: the contact email for a technical referent to be contacted for updates on the status of this IdP.
 * `nagiosserver`: This parameter permits to specify a Nagios server, if it contains a value different from
   undef NRPE daemon will be installed and configured to accept connections from the specified Nagios server.

After that, the example provided installs and configures the Shibboleth IdP on the Puppet agent machine.
At first it installs the prerequisites needed to the IdP to be installed.
Then downloads and installs the IdP Package from Internet2 Shibboleth.

The parameters that can be specified to describe a Shibboleth IdP instance are the following:
 * `metadata_information`: information to be put in metadata file into different languages (for instance Italian and English): 
   - `orgDisplayName`: Unit Organization Name in a user-friendly form.
   - `communityDesc`: Description for community managed from this IdP.
   - `orgUrl`: URL where an user can found more information about the Organization that owns this IdP.
   - `privacyPage`:URL where an user can found the Privacy Page for this IdP.
   - `nameOrg`: Unit Organization Name.
   - `idpInfoUrl`: URL where an user can found more information about this entity (IdP).
   - `url_LogoOrg-32x32`: URL where an user can found the Organization's Logo (32x32 px).
   - `url_LogoOrg-160x120`: URL where an user can found the Organization's Logo (160x120 px).
   - `technicalEmail`: An email address of the technical who manage the IdP.
   - `technicalIDPadminGivenName`: The Technical IDP Admin's name.
   - `technicalIDPadminSurName`: The Technical IDP Admin's surname.
   - `technicalIDPadminTelephone`: The Technical IDP Admin's telephone number.
   - `registrationInstant`: The instant when the entity was registered with the Authority
 * `shibbolethversion`: This parameter permits to specify the version of Shibboleth IdP to be downloaded
   from the Internet2 repositories. By default the 2.4.0 version will be downloaded.
 * `install_uapprove`: This parameter permits to specify if uApprove has to be installed on this IdP
 * `idpfqdn`: This parameters must contain the fully qualified domain name of the IdP. This name must be
   the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used
   to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified
   by the client, the client's browser will raise a security exception. 
 * `keystorepassword`: This parameter permits to specify the keystore password used to protect the keystore file
   on the IdP server.
 * `mailto`: The email address to be notified when the certificate used for HTTPS is about to expire.
   If no email address is specified, no mail warning will be sent.
 * `install_ldap`: This parameter permits to specify if an OpenLDAP server must be installed on the IdP machine or not.
 * `domain_name`: This parameter permits to specify the domain name for the LDAP user database.
 * `basedn`: This parameters must contain the base DN of the LDAP server. 
 * `rootdn`: This parameters must contain the CN for the user with root access to the LDAP server.
 * `rootpw`: This parameters must contain the password of the user with root access.
 * `rootldappw`: This parameters must contain the password of the user with root access to the LDAP server.
 * `ldap_host`: This parameter must contain the LDAP host the IdP will connect to (may be left undef if
   install_ldap is set to true).
 * `ldap_use_ssl`: This parameter must contain true of the LDAP connection must use SSL
   (may be left undef if install_ldap is set to true).
 * `ldap_use_tls`: This parameter must contain true of the LDAP connection must use TLS
   (may be left undef if install_ldap is set to true).
 * `logserver`: This parameter permits to specify if the logs should be sent to a centralized log server.
   In case this variable is not undef, rsyslog will be configured to send the logs to the specified server.
 * `sambadomain`: This parameter permits to specify the Samba domain name to be configured while installing Nagios.
 * `test_federation`: This parameter permits to specify if the IDP must be inserted into Test Federation (true) or into Production Federation (false).
 * `custom_styles`: This parameter permits to specify if the custom style of IdP Login Web Page must be installed (true) or not (false).
 * `first_install`: This parameter permits to specify if it is the first installation of IdP (true) or only an update (false).
 * `phpldap_easy_insert`: this parameter permits to specify whether the phpldapadmin interface provided for user management must be
   the complete one or the simplified version (true in this case implies that the simplified user management form will be installed).
 * `uapprove_version`: This parameter permits to choose which version of uApprove must be installed. The default version installed
   will be the '2.5.0'. The version tested are '2.4.1' and '2.5.0'.

check_password.so compilation
=============================
In this section the steps to build the check_password.so module for OpenLDAP Password Policy from source
will be described.

Access to you LDAP machine that you have installed with (debian) packages and following this commands:
* `cd /tmp ; sudo apt-get install dpkg-dev ; apt-get build-dep slapd ; apt-get source slapd`
* `cd /tmp/openldap-X.Y.ZZ ; ./configure ; make depend`
* `cd /tmp/openldap-X.Y.ZZ/servers/slapd/overlays ; wget  ...check_password.c`
* `gcc -fPIC -c -I../../../include -I.. check_password.c`
* `gcc -shared -o /usr/lib/ldap/check_password.so check_password.o`
* `service slapd restart`
