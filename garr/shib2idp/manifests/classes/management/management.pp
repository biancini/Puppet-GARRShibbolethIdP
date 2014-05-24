# == Class: shib2idp::management::management
#
# This class installs useful monitoring tools.
#
# Parameters:
# +install_ldap+:: This parameter permits to specify if an OpenLDAP server must be installed on the IdP machine or not.
# +install_uapprove+:: This parameter permits to specify if uApprove has to be installed on this IdP
# +logserver+:: This parameter permits to specify if the logs should be sent to a centralized log server. In case this variable is not undef, rsyslog will be configured to send the logs to the specified server.
# +nagiosserver+:: This parameter permits to specify a Nagios server, if it contains a value different from undef NRPE daemon will be installed and configured to accept connections from the specified Nagios server.
# +collectdserver+::
# +sambadomain+:: This parameter permits to specify the Samba domain name to be configured while installing Nagios.
# +idpfqdn+:: This parameters must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
# +basedn+:: This parameters must contain the base DN of the LDAP server.
# +rootdn+:: This parameters must contain the CN for the user with root access to the LDAP server.
# +rootldappw+:: This parameters must contain the password of the user with root access to the LDAP server.
# +domain_name+:: This parameter permits to specify the domain name for the LDAP user database.
# +rootpw+:: This parameters must contain the password of the user with root access.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::management (
  $metadata_information,
  $install_ldap        = true,
  $install_uapprove    = undef,
  $logserver           = undef,
  $nagiosserver        = undef,
  $collectdserver      = undef,
  $sambadomain         = 'WORKGROUP',
  $idpfqdn             = 'puppetclient.example.com',
  $basedn              = 'dc=example,dc=com',
  $rootdn              = 'cn=admin',
  $rootldappw          = 'ldappassword',
  $domain_name         = undef,
  $rootpw              = undef,
  $technical_email     = undef,
  $test_federation     = undef,
  $phpldap_easy_insert = undef,
) {
  # Adding classes for rsyslog, nagios and collectd
  class {
    'shib2idp::management::rsyslog':
      logserver => $logserver;

    'shib2idp::management::nagios':
      install_uapprove => $install_uapprove,
      nagiosserver     => $nagiosserver,
      sambadomain      => $sambadomain,
      idpfqdn          => $idpfqdn,
      basedn           => $basedn,
      rootdn           => $rootdn,
      rootpw           => $rootpw,
      rootldappw       => $rootldappw;

    'shib2idp::management::collectd':
      collectdserver => $collectdserver,
      idpfqdn        => $idpfqdn,
      basedn         => $basedn,
      rootdn         => $rootdn,
      rootpw         => $rootpw,
      rootldappw     => $rootldappw;
  }

  # Adding class for the php interface of LDAP, if required
  if ($install_ldap == true) {
    class { 'shib2idp::management::phpldap':
      idpfqdn              => $idpfqdn,
      basedn               => $basedn,
      rootdn               => $rootdn,
      rootldappw           => $rootldappw,
      domain_name          => $domain_name,
      technical_email      => $technical_email,
      metadata_information => $metadata_information,
      easy_insert          => $phpldap_easy_insert,
      notify               => Exec['shib2-apache-restart']
    }
  }

  # Adding statiscics class
  class { 'shib2idp::management::statistics':
    rootpw          => $rootpw,
    idpfqdn         => $idpfqdn,
    test_federation => $test_federation,
    notify          => Exec['shib2-apache-restart']
  }
  
}
