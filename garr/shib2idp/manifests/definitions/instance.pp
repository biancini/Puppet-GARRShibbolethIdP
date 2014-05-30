# == Define: shib2idp::instance
#
# This define installs and configures the Shibboleth IdP on the Puppet agent machine.
# At first it installs the prerequisites needed to the IdP to be installed.
# Then downloads and installs the IdP Package from Internet2 Shibboleth repositories.
#
# Parameters:
# +shibbolethversion+:: This parameter permits to specify the version of Shibboleth IdP to be downloaded from the Internet2 repositories. By default the 2.3.3 version will be downloaded.
# +install_uapprove+:: This parameter permits to specify if uApprove has to be installed on this IdP
# +install_ldap+:: This parameter permits to specify if an OpenLDAP server must be installed on the IdP machine or not.
# +domain_name+:: This parameter permits to specify the domain name for the LDAP user database.
# +basedn+:: This parameters must contain the base DN of the LDAP server.
# +rootdn+:: This parameters must contain the CN for the user with root access to the LDAP server.
# +rootpw+:: This parameters must contain the password of the user with root access.
# +rootldappw+:: This parameters must contain the password of the user with root access to the LDAP server.
# +ldap_host+:: This parameter must contain the LDAP host the IdP will connect to (may be left undef if install_ldap is set to true).
# +ldap_use_ssl+:: This parameter must contain true of the LDAP connection must use SSL (may be left undef if install_ldap is set to true).
# +ldap_use_tls+:: This parameter must contain true of the LDAP connection must use TLS (may be left undef if install_ldap is set to true).
# +logserver+:: This parameter permits to specify if the logs should be sent to a centralized log server. In case this variable is not undef, rsyslog will be configured to send the logs to the specified server.
# +nagiosserver+:: This parameter permits to specify a Nagios server, if it contains a value different from undef NRPE daemon will be installed and configured to accept connections from the specified Nagios server.
# +sambadomain+:: This parameter permits to specify the Samba domain name to be configured while installing Nagios.
# +metadata_information+:: Information to be put in metadata file into English and Italian language:
#  * _orgDisplayName_:: Unit Organization Name in a user-friendly form.
#  * _communityDesc_:: Description for community managed from this IdP.
#  * _orgUrl_:: URL where an user can found more information about the Organization that owns this IdP.
#  * _privacyPage_:: URL where an user can found the Privacy Page for this IdP.
#  * _nameOrg_:: Unit Organization Name
#  * _idpInfoUrl_:: URL where an user can found more information about this entity (IdP)
#  * _url_LogoOrg-32x32_:: URL where an user can found the Organization's Logo (32x32 px)
#  * _url_LogoOrg-160x120_:: URL where an user can found the Organization's Logo (160x120 px)
#
#  * _technicalEmail_:: An email address of the technical who manage the IdP
#
# Actions:
#
# Requires:
#
# Sample Usage:
# To install Shibboleth IdP on a node the following example configuration should be put into the site.pp file on the Puppet Master:
#
#
#   node 'agenthostname' {
#     class { 'shib2idp::iptables':
#       iptables_enable_network => '192.168.56.0/24',
#     }
#
#    shib2idp::instance { "${hostname}-idp":
#       metadata_information => {
#         'en' => {
#           'orgDisplayName'    => 'Test IdP for IdP in the cloud project',
#           'communityDesc'     => 'GARR Research &amp; Development',
#           'orgUrl'            => 'http://www.garr.it/',
#           'privacyPage'       => 'http://www.garr.it/',
#           'nameOrg'           => 'Consortium GARR',
#           'idpInfoUrl'        => 'https://puppetclient.example.com/idp/info.html',
#           'url_LogoOrg-32x32' => 'https://puppetclient.example.com/idp/images/institutionLogo-32x32_en.png',
#           'url_LogoOrg-160x120' => 'https://puppetclient.example.com/idp/images/institutionLogo-160x120_en.png',
#         },
#         'it' => {
#           'orgDisplayName'    => 'Test IdP for IdP in the cloud project',
#           'communityDesc'     => 'GARR Research &amp; Development',
#           'orgUrl'            => 'http://www.garr.it/',
#           'privacyPage'       => 'http://www.garr.it/',
#           'nameOrg'           => 'Consortium GARR',
#           'idpInfoUrl'        => 'https://puppetclient.example.com/idp/info.html',
#           'url_LogoOrg-32x32' => 'https://puppetclient.example.com/idp/images/institutionLogo-32x32_it.png',
#           'url_LogoOrg-160x120' => 'https://puppetclient.example.com/idp/images/institutionLogo-160x120_it.png',
#         },
#         'technicalEmail' => 'support@pupperclient.example.com',
#         'technicalIDPadminGivenName' => '',
#         'technicalIDPadminSurName'   => '',
#         'technicalIDPadminTelephone' => '',
#         'registrationInstant'        => '2013-06-27T12:00:00Z',
#       },
#       shibbolethversion       => '2.4.0',
#       install_uapprove        => true,
#       install_ldap            => true,
#       domain_name             => 'example.com',
#       basedn                  => 'dc=example,dc=com',
#       rootdn                  => 'cn=admin',
#       rootpw                  => 'ldappassword',
#       rootldappw              => 'ldappassword',
#       ldap_host               => undef,
#       ldap_use_ssl            => undef,
#       ldap_use_tls            => undef,
#       logserver               => undef,
#       collectdserver          => undef,
#       nagiosserver            => undef,
#       sambadomain             => 'WORKGROUP',
#     }
#   }
#
define shib2idp::instance (
  $metadata_information,
  $shibbolethversion       = undef,
  $install_uapprove        = undef,
  $install_ldap            = undef,
  $domain_name             = undef,
  $basedn                  = undef,
  $rootdn                  = undef,
  $rootpw                  = undef,
  $idpfqdn                 = undef,
  $mailto                  = undef,
  $keystorepassword        = undef,
  $rootldappw              = undef,
  $ldap_host               = undef,
  $ldap_use_ssl            = undef,
  $ldap_use_tls            = undef,
  $logserver               = undef,
  $nagiosserver            = undef,
  $collectdserver          = undef,
  $sambadomain             = undef,
  $test_federation         = undef,
  $custom_styles           = undef,
  $additional_metadata     = undef,
  $first_install           = true,
  $phpldap_easy_insert     = undef,
  $uapprove_version        = undef,
) {
  
  class { 'shib2idp::prerequisites':
    rootpw                  => $rootpw,
    idpfqdn                 => $idpfqdn,
    mailto                  => $mailto,
  }

  # Install and configure Shibboleth IdP from Internet2
  class { 'shib2idp::idp':
    metadata_information => $metadata_information,
    shibbolethversion    => $shibbolethversion,
    install_uapprove     => $install_uapprove,
    idpfqdn              => $idpfqdn,
    keystorepassword     => $keystorepassword,
    mailto               => $mailto,
    install_ldap         => $install_ldap,
    domain_name          => $domain_name,
    basedn               => $basedn,
    rootdn               => $rootdn,
    rootpw               => $rootpw,
    rootldappw           => $rootldappw,
    ldap_host            => $ldap_host,
    ldap_use_ssl         => $ldap_use_ssl,
    ldap_use_tls         => $ldap_use_tls,
    nagiosserver         => $nagiosserver,
    test_federation      => $test_federation,
    custom_styles        => $custom_styles,
    additional_metadata  => $additional_metadata,
    first_install        => $first_install,
    uapprove_version     => $uapprove_version,
  }
  
  # Install monitoring tools
  class { 'shib2idp::management':
    install_ldap         => $install_ldap,
    install_uapprove     => $install_uapprove,
    logserver            => $logserver,
    nagiosserver         => $nagiosserver,
    collectdserver       => $collectdserver,
    sambadomain          => $sambadomain,
    idpfqdn              => $idpfqdn,
    basedn               => $basedn,
    rootdn               => $rootdn,
    rootldappw           => $rootldappw,
    rootpw               => $rootpw,
    domain_name          => $domain_name,
    metadata_information => $metadata_information,
    technical_email      => $metadata_information['technicalEmail'],
    test_federation      => $test_federation,
    phpldap_easy_insert  => $phpldap_easy_insert,
  }

  $curtomcat = $::tomcat::curtomcat
  if ($test_federation){
    File['metadata-test-federation.xml']~>Exec['shib2-tomcat-restart']  

    download_file{ '/opt/shibboleth-idp/metadata/idem-test-metadata-sha256.xml':
      url     => "http://www.garr.it/idem-metadata/idem-test-metadata-sha256.xml",
      require => Shibboleth_install['execute_install'],
    }

    file { 'metadata-test-federation.xml':
      path  => '/opt/shibboleth-idp/metadata/idem-test-metadata-sha256.xml',
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0644',
      require => Download_file['/opt/shibboleth-idp/metadata/idem-test-metadata-sha256.xml'],
    }
  
    file { 'metadata-federation.xml':
      path  => '/opt/shibboleth-idp/metadata/idem-metadata-sha256.xml',
      ensure  => absent,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0644',
    }
  }
  else{
    File['metadata-federation.xml']~>Exec['shib2-tomcat-restart']

    download_file{ '/opt/shibboleth-idp/metadata/idem-metadata-sha256.xml':
      url   => "http://www.garr.it/idem-metadata/idem-metadata-sha256.xml",
    }

    file { 'metadata-federation.xml':
      path  => '/opt/shibboleth-idp/metadata/idem-metadata-sha256.xml',
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0644',
      require => Download_file['/opt/shibboleth-idp/metadata/idem-metadata-sha256.xml'],
    }

    file { 'metadata-test-federation.xml':
      path  => '/opt/shibboleth-idp/metadata/idem-test-metadata-sha256.xml',
      ensure  => absent,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0644',
    }
  }

  # if ($install_ldap == true) {
  #  Exec['shib2-tomcat-restart'] ~> Verify_user<| title == 'uid=test,ou=people' |>
  #
  #  verify_user{ "uid=test,ou=people":
  #    basedn => $basedn,
  #    adminuser => "${rootdn}",
  #    ldappasswd => $rootldappw,
  #    ldapsrv => $shib2idp::idp::finalize::ldap_host_var,
  #    ssl => $shib2idp::idp::finalize::ldap_use_ssl_var,
  #    tls => $shib2idp::idp::finalize::ldap_use_ssl_var,
  #    require => [Execute_ldap['ldapadd-test-user'], Class['shib2idp::idp']]
  #  }
  #}
}
