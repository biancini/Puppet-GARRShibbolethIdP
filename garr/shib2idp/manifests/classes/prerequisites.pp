# == Class: shib2idp::prerequisites
#
# This class permits to install all prerequisites to Shibboleth IdP on the Puppet agent machine.
# This class installs requested packages, installs the Java JDK and Tomcat6.
#
# Parameters:
# +configure_admin+:: This param permits to specify if the Tomcat administration interface has to be installed on the Tomcat instance or not. If set to true the administration interface is installed and will be accessible on the port 8080 of the Puppet agent machine.
# +tomcat_admin_password+:: If the Tomcat administration interface is going to be installed this parameter permits to specify the password for the 'admin' user used by tomcat to access the administration interface.
# +tomcat_manager_password+:: If the Tomcat administration interface is going to be installed this parameter permits to specify the password for the 'manager' user used by tomcat to access the administration interface.
# +rootpw+:: This parameters must contain the password of the user with root access to the LDAP server.
# +mailto+:: The email address to be notified when the certificate used for HTTPS is about to expire. if no email address is specified, no mail warning will be sent.
# +idpfqdn+:: This parameters must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
class shib2idp::prerequisites (
  $rootpw     = 'idppuppetsecret',
  $idpfqdn    = 'idp.example.org', 
  $mailto     = '',
) {

  # Install java (this operation also performs apt-get updated needed by further packages)
  include shib2common::java::package
  # include shib2common::java::download
  $java_home = $shib2common::java::params::java_home
  $java_opts = $shib2common::java::params::java_opts

  if rubyversion == '1.8.7'{
     package { ['libldap-ruby1.8', 'gettext', 'python-ldap']: 
        ensure => installed,
     }
  }
  # Else Ruby > 1.8 (1.9.3)
  else{

     package { 'libldap-ruby1.8': 
        ensure => purged,
     }

     package { ['ruby-ldap', 'gettext', 'python-ldap']: 
        ensure => installed,
     }
  }

  include 'concat::setup'

  apache::mod { 'actions': }
  
  file {
    "/etc/apache2/sites-available/idp.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
            content => join(['## Proxy rules',
                       'ProxyRequests Off',
                       '<Proxy *>',
                       '  Order deny,allow',
                       '  Allow from all',
                       '</Proxy>',
                       '',
                       'ProxyPass /idp ajp://localhost:8009/idp',
                       'ProxyPassReverse /idp ajp://localhost:8009/idp'], "\n"),
      require => [Class['apache', 'apache::mod::ssl'], Apache::Mod['proxy_ajp']];

    "/etc/apache2/sites-enabled/idp.conf":
      ensure  => link,
      target  => "/etc/apache2/sites-available/idp.conf",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File["/etc/apache2/sites-available/idp.conf"],
      notify => Service ['httpd'];
  }
  
  $proxy_pass_idp = [
     { 'path' => '/idp', 'url' => 'ajp://localhost:8009/idp' },
  ]
  
  apache::vhost { 'idp-ssl-8443':
    servername        => "${idpfqdn}:8443",
    port              => '8443',
    serveradmin       => $mailto,
    docroot           => '/var/www',
    ssl               => true,
    ssl_cert          => '/opt/shibboleth-idp/credentials/idp.crt',
    ssl_key           => '/opt/shibboleth-idp/credentials/idp.key',
    ssl_protocol      => 'All -SSLv2 -SSLv3',
    ssl_cipher        => 'ALL:!ADH:!RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP',
    add_listen        => true,
    error_log         => true,
    error_log_file    => 'error.log',
    access_log        => true,
    access_log_file   => 'ssl_access.log',
    access_log_format => 'combined',
    proxy_pass        => $proxy_pass_idp,
    custom_fragment   => '
  <Directory /usr/lib/cgi-bin>
     SSLOptions +StdEnvVars
  </Directory>

  #   SSL Protocol Adjustments:
  #   The safe and default but still SSL/TLS standard compliant shutdown
  #   approach is that mod_ssl sends the close notify alert but doesn\'t wait for
  #   the close notify alert from client. When you need a different shutdown
  #   approach you can use one of the following variables:
  #   o ssl-unclean-shutdown:
  #     This forces an unclean shutdown when the connection is closed, i.e. no
  #     SSL close notify alert is send or allowed to received.  This violates
  #     the SSL/TLS standard but is needed for some brain-dead browsers. Use
  #     this when you receive I/O errors because of the standard approach where
  #     mod_ssl sends the close notify alert.
  #   o ssl-accurate-shutdown:
  #     This forces an accurate shutdown when the connection is closed, i.e. a
  #     SSL close notify alert is send and mod_ssl waits for the close notify
  #     alert of the client. This is 100% SSL/TLS standard compliant, but in
  #     practice often causes hanging connections with brain-dead browsers. Use
  #     this only for browsers where you know that their SSL implementation
  #     works correctly.
  #   Notice: Most problems of broken clients are also related to the HTTP
  #   keep-alive facility, so you usually additionally want to disable
  #   keep-alive for those clients, too. Use variable "nokeepalive" for this.
  #   Similarly, one has to force some clients to use HTTP/1.0 to workaround
  #   their broken HTTP/1.1 implementation. Use variables "downgrade-1.0" and
  #   "force-response-1.0" for this.
  BrowserMatch "MSIE [2-6]" \
     nokeepalive ssl-unclean-shutdown \
     downgrade-1.0 force-response-1.0
  # MSIE 7 and newer should be able to use keepalive
  BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
  ',
    require           => [Class['apache::mod::ssl'], Apache::Mod['proxy_ajp'], Idp_metadata['/opt/shibboleth-idp/metadata/idp-metadata.xml']],
  }

  # Install mysql-server and set the root's password to access it
  class { 'mysql::server':
    root_password => $rootpw
  }

  # Install the mysql-java-connector
  class { 'mysql::bindings':
    java_enable => true,
    require     => Class['mysql::server', 'shib2common::java::package']
  }
}

