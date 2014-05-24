# == Class: shib2idp::management::collectd
#
# This class installs and configures the CollectD Server on IdP.
#
# Parameters:
# +collectdserver+::
# +idpfqdn+:: This parameters must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
# +basedn+:: This parameters must contain the base DN of the LDAP server.
# +rootdn+:: This parameters must contain the CN for the user with root access to the LDAP server.
# +rootpw+:: This parameters must contain the password of the user with root access.
# +rootldappw+:: This parameters must contain the password of the user with root access to the LDAP server.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::management::collectd (
  $collectdserver = undef,
  $idpfqdn        = 'puppetclient.example.com',
  $basedn         = 'dc=example,dc=com',
  $rootdn         = 'cn=admin',
  $rootpw         = 'ldappassword',
  $rootldappw     = 'ldappassword',) {
  # Configuration of CollectD server
  package {
    ['collectd','rrdtool', 'collectd-dev', 'lm-sensors', 'liboping0']:
      ensure => present;

    ['libregexp-common-perl', 'libconfig-general-perl', 'libhtml-parser-perl', 'librrds-perl', 'mbmon']:
      ensure => present;
  }

  if ($collectdserver) {
    file { '/etc/collectd/collectd.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/collectdconf.erb"),
      require => Package['collectd'],
      notify  => Exec['collectd-restart'],
    }

    exec { 'collectd-restart':
      command     => "/usr/sbin/service collectd restart",
      refreshonly => true,
    }
  } else {
    file {
      "/etc/apache2/sites-available/collectd":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => join([
          'ScriptAlias /collectd/bin/ /usr/share/doc/collectd-core/examples/collection3/bin/',
          'Alias /collectd/ /usr/share/doc/collectd-core/examples/collection3/',
          '',
          '<Directory /usr/share/doc/collectd-core/examples/collection3/>',
          '        AddHandler cgi-script .cgi',
          '        DirectoryIndex bin/index.cgi',
          '        Options +ExecCGI',
          '        Order Allow,Deny',
          '        Allow from all',
          '</Directory>'], "\n");

      "/etc/apache2/sites-enabled/collectd":
        ensure  => link,
        target  => "/etc/apache2/sites-available/collectd",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["/etc/apache2/sites-available/collectd"],
        notify  => Exec['collectd-apache-reload'],
    }

    exec { 'collectd-apache-reload':
      command     => "/usr/sbin/service apache2 reload",
      refreshonly => true,
    }
  }
}
