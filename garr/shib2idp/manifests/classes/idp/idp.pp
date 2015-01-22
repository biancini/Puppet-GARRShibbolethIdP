# == Class: shib2idp::idp::idp
#
# This class installs and configures the Shibboleth IdP on the Puppet agent machine.
# This class executes a lot of installation and configuration operations in a staged way.
#
# The main stages of installation for the Shibboleth IdP are as follows:
# - unpack: these operations are used to download the Internet2 Shibboleth implementation from their repository and to unpack it in /usr/local/src folder.
# - install: these operations are used to execute the setup.sh script inside the Internet2 Shibboleth package downloaded from their repositories.
# - configure: these operations are used to configure all Tomcat connectors and web applications to support Shibboleth IdP execution.
# - security: these operations are used to register all security providers used by the Shibboleth IdP package into java.security on the Puppet agent machine.
# - finalize:  these operations are used to finalize IdP configuration, to register all attribute resolver and attribute filters.
#
# To control the installation process, and to guarantee that an installation is able to continue
# from a previously interrupted one, a semaphore system has been implemented. This semaphore
# uses the file /usr/local/src/shibboleth-identityprovider/.puppet to retrieve the last executed
# installation phase and eventually to continue from that point on.
#
# Parameters:
# +metadata_information+:: Information to be put in metadata file into English and Italian language.
# +shibbolethversion+:: This parameter permits to specify the version of Shibboleth IdP to be downloaded from the Internet2 repositories. By default the 2.3.3 version will be downloaded.
# +install_uapprove+:: This parameter permits to specify if uApprove has to be installed on this IdP.
# +idpfqdn+:: This parameters must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
# +keystorepassword+:: This parameter permits to specify the keystore password used to protect the keystore file on the IdP server.
# +mailto+:: The email address to be notified when the certificate used for HTTPS is about to expire. if no email address is specified, no mail warning will be sent.
# +install_ldap+:: This parameter permits to specify if an OpenLDAP server must be installed on the IdP machine or not.
# +domain_name+:: This parameter permits to specify the domain name for the LDAP user database.
# +basedn+:: This parameters must contain the base DN of the LDAP server.
# +rootdn+:: This parameters must contain the CN for the user with root access to the LDAP server.
# +rootpw+:: This parameters must contain the password of the user with root access.
# +rootldappw+:: This parameters must contain the password of the user with root access to the LDAP server.
# +ldap_host+:: This parameter must contain the LDAP host the IdP will connect to (may be left undef if install_ldap is set to true).
# +ldap_use_ssl+:: This parameter must contain true of the LDAP connection must use SSL (may be left undef if install_ldap is set to true).
# +ldap_use_tls+:: This parameter must contain true of the LDAP connection must use TLS (may be left undef if install_ldap is set to true).
# +nagiosserver+:: This parameter permits to specify a Nagios server, if it contains a value different from 'undef' NRPE daemon will be installed and configured to accept connections from the specified Nagios server.
# +custom_styles+:: This parameter permits to decide if install the default IdP style or the custom one.
# +additional_metadata+:: undef,
# +uapprove_version+:: This parameter must contain the uApprove's version number to be installed.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::idp (
  $metadata_information,
  $shibbolethversion = '2.4.0',
  $install_uapprove  = undef,
  $idpfqdn           = undef,
  $keystorepassword  = undef,
  $mailto            = undef,
  $install_ldap      = undef,
  $domain_name       = undef,
  $basedn            = undef,
  $rootdn            = undef,
  $rootpw            = undef,
  $rootldappw        = 'ldappassword',
  $ldap_host         = undef,
  $ldap_use_ssl      = undef,
  $ldap_use_tls      = undef,
  $nagiosserver      = undef,
  $test_federation   = undef,
  $custom_styles     = undef,
  $uapprove_version  = '2.5.0',
) {
  $curtomcat = $::tomcat::curtomcat

  # Download and unpack Shibboleth source files from Internet2 site
  Download_file <| title == "/usr/local/src/shibboleth-identityprovider-${shibbolethversion}" |> ~> Shibboleth_install <| title == 'execute_install' |>

  download_file { "/usr/local/src/shibboleth-identityprovider-${shibbolethversion}":
    url             => "http://shibboleth.net/downloads/identity-provider/${shibbolethversion}/shibboleth-identityprovider-${shibbolethversion}-bin.zip",
    #url             => "http://${::pupmaster}/downloads/shibboleth-identityprovider-${shibbolethversion}-bin.zip",
    extract         => 'zip',
    execute_command => [
      "/usr/bin/find /usr/local/src/shibboleth-identityprovider-${shibbolethversion} -type d -exec /bin/chmod 755 {} \\;",
      "/usr/bin/find /usr/local/src/shibboleth-identityprovider-${shibbolethversion} -type f -exec /bin/chmod 644 {} \\;",],
  }

  # Checks and create needed folders
  $overwrite_idp_install = empty($::idpmetadata)

  file {
    '/usr/local/src/shibboleth-identityprovider':
      ensure  => link,
      target  => "/usr/local/src/shibboleth-identityprovider-${shibbolethversion}",
      require => Download_file["/usr/local/src/shibboleth-identityprovider-${shibbolethversion}"];

    '/opt/shibboleth-idp/':
      ensure => directory;

    '/opt/shibboleth-idp/conf/':
      ensure  => directory,
      require => File['/opt/shibboleth-idp/'];

    '/usr/local/src/shibboleth-identityprovider/src/installer/resources/build.xml':
      ensure  => present,
      content => template("shib2idp/build.xml.erb"),
      require => Download_file["/usr/local/src/shibboleth-identityprovider-${shibbolethversion}"];

    '/usr/local/src/shibboleth-identityprovider/lib/ldaptive.jar':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/jars/ldaptive.jar",
      require => Download_file["/usr/local/src/shibboleth-identityprovider-${shibbolethversion}"];
      
    '/usr/local/src/shibboleth-identityprovider/lib/garr-ldaptive.jar':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/jars/garr-ldaptive.jar",
      require => Download_file["/usr/local/src/shibboleth-identityprovider-${shibbolethversion}"];

  }

  # If has to, installs uApprove
  if ($install_uapprove) {
    Download_file <| title == "/usr/local/src/shibboleth-identityprovider-${shibbolethversion}" |> -> Class['shib2idp::idp::uapprove']
    Class['shib2idp::idp::uapprove'] ~> Shibboleth_install <| title == 'execute_install' |>

    class { 'shib2idp::idp::uapprove':
      rootldappw        => $rootldappw,
      shibbolethversion => $shibbolethversion,
      uapprove_version  => $uapprove_version,
      install_uapprove  => $install_uapprove,
      nagiosserver      => $nagiosserver,
      require           => File['/opt/shibboleth-idp/', '/opt/shibboleth-idp/conf/'],
    }
  }

  # Install the Shibboleth style
  Download_file <| title == "/usr/local/src/shibboleth-identityprovider-${shibbolethversion}" |> -> Class['shib2idp::idp::styles']
  Class['shib2idp::idp::styles'] ~> Shibboleth_install <| title == 'execute_install' |>

  class { 'shib2idp::idp::styles':
    install_ldap_var => $install_ldap,
    custom_styles => $custom_styles,
    metadata_information => $metadata_information,
    install_uapprove => $install_uapprove,
    require => File['/opt/shibboleth-idp/', '/opt/shibboleth-idp/conf/'],
  }

  # Install the Shibboleth IdP
  Shibboleth_install <| title == 'execute_install' |> ~> Service["${curtomcat}"]
  Shibboleth_install <| title == 'execute_install' |> ~> Service['httpd']

  shibboleth_install { 'execute_install':
    idpfqdn          => $idpfqdn,
    keystorepassword => $keystorepassword,
    javahome         => $shib2idp::prerequisites::java_home,
    tomcathome       => $tomcat::tomcat_home,
    curtomcat        => $curtomcat,
    require          => [Class['shib2common::java::package', 'tomcat'], File['/usr/local/src/shibboleth-identityprovider/src/installer/resources/build.xml']],
  }

  if ($install_uapprove) {
    file {
      "/opt/shibboleth-idp/conf/uApprove.xml":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/uapprove.xml",
        require => [File['/opt/shibboleth-idp/conf/'], Shibboleth_install['execute_install']];

      "/opt/shibboleth-idp/conf/uApprove.properties":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/uapprove.properties.erb"),
        require => [File['/opt/shibboleth-idp/conf/'], Shibboleth_install['execute_install']];

      "/opt/shibboleth-idp/conf/sql-statements.properties":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/sql-statements.properties",
        require => [File['/opt/shibboleth-idp/conf/'], Shibboleth_install['execute_install']];
    }
  }

  # Configure the Shibboleth IdP
  Class['shib2idp::idp::configure'] ~> Service["${curtomcat}"]
  Class['shib2idp::idp::configure'] ~> Service['httpd']

  class { 'shib2idp::idp::configure':
    idpfqdn          => $idpfqdn,
    keystorepassword => $keystorepassword,
    require          => Shibboleth_install['execute_install'],
  }

  # Finalize the installation of the Shibboleth IdP
  Class['shib2idp::idp::finalize'] ~> Service["${curtomcat}"]
  Class['shib2idp::idp::finalize'] ~> Service['httpd']

  class { 'shib2idp::idp::finalize':
    metadata_information => $metadata_information,
    install_ldap         => $install_ldap,
    domain_name          => $domain_name,
    basedn               => $basedn,
    rootdn               => $rootdn,
    rootpw               => $rootpw,
    rootldappw           => $rootldappw,
    ldap_host            => $ldap_host,
    ldap_use_ssl         => $ldap_use_ssl,
    ldap_use_tls         => $ldap_use_tls,
    idpfqdn              => $idpfqdn,
    nagiosserver         => $nagiosserver,
    test_federation      => $test_federation,
  }

}
