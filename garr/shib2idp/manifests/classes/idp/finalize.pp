# == Class: shib2idp::idp::finalize
#
# This class executes the finalize stage of the installation and configuration of the
# Shibboleth IdP on the Puppet agent machine.
#
# The finalize operations are used to finalize IdP configuration, to register all attribute
# resolver and attribute filters. 
#
# Parameters:
# +install_ldap+:: This parameter permits to specify if an OpenLDAP server must be installed on the IdP machine or not.
# +domain_name+:: This parameter permits to specify the domain name for the LDAP user database.
# +basedn+:: This parameter must contain the base DN of the LDAP server. 
# +rootdn+:: This parameter must contain the CN for the user with root access to the LDAP server.
# +rootpw+:: This parameter must contain the password of the user with root access.
# +rootldappw+:: This parameter must contain the password of the user with root access to the LDAP server.
# +ldap_host+:: This parameter must contain the LDAP host the IdP will connect to (may be left undef if install_ldap is set to true).
# +ldap_use_ssl+:: This parameter must contain true of the LDAP connection must use SSL (may be left undef if install_ldap is set to true).
# +ldap_use_tls+:: This parameter must contain true of the LDAP connection must use TLS (may be left undef if install_ldap is set to true).
# +idpfqdn+:: This parameter must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
# +test_federation+:: = This parameter must contain 'true' to retrieve the test federation's metadata.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::idp::finalize (
  $metadata_information,
  $install_ldap = true,
  $domain_name  = 'example.com',
  $basedn       = 'dc=example,dc=com',
  $rootdn       = 'cn=admin',
  $rootpw       = 'ldappassword',
  $rootldappw   = 'ldappassword',
  $ldap_host    = undef,
  $ldap_use_ssl = undef,
  $ldap_use_tls = undef,
  $nagiosserver = undef,
  $idpfqdn      = 'idp.example.org',
  $test_federation = true,
) {

  $test_federation_var = $test_federation
  $curtomcat = $::tomcat::curtomcat

  file_line {
    'idp_log_1':
      ensure => present,
      path   => '/etc/environment',
      line   => "IDP_LOG=/opt/shibboleth-idp/logs/idp-process.log";

    'idp_log_2':
      ensure => present,
      path   => '/etc/environment',
      line   => "TOMCAT_LOG_DIR=/var/log/${curtomcat}/";
  }

  if ($install_ldap) {
    class { 'ldap':
      server => 'true',
      ssl    => 'false',
    }

    ldap::define::domain { $domain_name:
      basedn => $basedn,
      rootdn => $rootdn,
      rootpw => $rootldappw,
    }
    
    ldap::define::acl { "dn.subtree=\"ou=people,${basedn}\" attrs=userPassword":
      domain     => $domain_name,
      access     => {
        "*"                          => none,
        "anonymous"                  => auth,
        "self"                       => write,
        "dn=\"${rootdn},${basedn}\"" => write,
      },
    }

    file {
      "/etc/ldap/schema/eduperson-200412.schema":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/eduperson-200412.schema",
        require => Package[$ldap::params::openldap_packages],
        notify  => Service[$ldap::params::lp_openldap_service];

      "/etc/ldap/schema/eduperson-200412.ldif":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/eduperson-200412.ldif",
        require => Package[$ldap::params::openldap_packages],
        notify  => Service[$ldap::params::lp_openldap_service];

      "/etc/ldap/schema/schac-20110705-1.4.1.schema":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/schac-20110705-1.4.1.schema",
        require => Package[$ldap::params::openldap_packages],
        notify  => Service[$ldap::params::lp_openldap_service];

      "/etc/ldap/schema/schac-20110705-1.4.1.ldif":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/schac-20110705-1.4.1.ldif",
        require => Package[$ldap::params::openldap_packages],
        notify  => Service[$ldap::params::lp_openldap_service];

      "/etc/ldap/schema/ppolicy.ldif":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/ppolicy.ldif",
        require => Package[$ldap::params::openldap_packages],
        notify  => Service[$ldap::params::lp_openldap_service];

      "/etc/ldap/schema/ppolicy.schema":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/ppolicy.schema",
        require => [Package[$ldap::params::openldap_packages], File['/usr/lib/ldap/check_password.so']],
        notify  => Service[$ldap::params::lp_openldap_service];

      '/etc/cron.hourly/lockusers':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('shib2idp/monitoring/lockusers.py.erb');
    }

    if ($operatingsystem == 'Ubuntu' and $operatingsystemrelease == '14.04') {
     file { '/usr/lib/ldap/check_password.so':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/shib2idp/ppolicy_modules/ldap-2-4-31-check_password.so',
        require => Package[$ldap::params::openldap_packages],
        notify  => Service[$ldap::params::lp_openldap_service],
      }
    }
    else {
     file { '/usr/lib/ldap/check_password.so':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/shib2idp/ppolicy_modules/ldap-2-4-28-check_password.so',
        require => Package[$ldap::params::openldap_packages],
        notify  => Service[$ldap::params::lp_openldap_service],
      }
    }

    file_line {
      'eduperson-schema':
        ensure  => present,
        path    => '/etc/ldap/schema.conf',
        line    => 'include /etc/ldap/schema/eduperson-200412.schema',
        require => [Package[$ldap::params::openldap_packages], File['/etc/ldap/schema/eduperson-200412.schema']],
        notify  => Service[$ldap::params::lp_openldap_service];

      'schac-schema':
        ensure  => present,
        path    => '/etc/ldap/schema.conf',
        line    => 'include /etc/ldap/schema/schac-20110705-1.4.1.schema',
        require => [Package[$ldap::params::openldap_packages], File['/etc/ldap/schema/schac-20110705-1.4.1.schema']],
        notify  => Service[$ldap::params::lp_openldap_service];
    }

    if $rubyversion == "1.8.7" {
      execute_ldap {
        'ldapadd-ppolicies-ou':
	        rootdn      => "${rootdn},${basedn}",
	        rootpw      => $rootldappw,
	        ldif_search => "ou=policies,${basedn}",
	        ldif        => template("shib2idp/ppolicy_ou.ldif.erb"),
	        require     => [Service[$ldap::params::lp_openldap_service], Package['libldap-ruby1.8']];
      
        'ldapadd-ppolicies-entity':
          rootdn      => "${rootdn},${basedn}",
          rootpw      => $rootldappw,
          ldif_search => "cn=default,ou=policies,${basedn}",
          ldif        => template("shib2idp/ppolicy_entity.ldif.erb"),
          require     => [Execute_ldap['ldapadd-ppolicies-ou'], Package['libldap-ruby1.8'], File['/usr/lib/ldap/check_password.so']],
      }
    }
    # Ruby on Ubuntu 14.04 == 1.9.3
    else{
      execute_ldap {
        'ldapadd-ppolicies-ou':
          rootdn      => "${rootdn},${basedn}",
          rootpw      => $rootldappw,
          ldif_search => "ou=policies,${basedn}",
          ldif        => template("shib2idp/ppolicy_ou.ldif.erb"),
          require     => [Service[$ldap::params::lp_openldap_service], Package['ruby-ldap']];
          
        'ldapadd-ppolicies-entity':
	         rootdn      => "${rootdn},${basedn}",
	         rootpw      => $rootldappw,
	         ldif_search => "cn=default,ou=policies,${basedn}",
	         ldif        => template("shib2idp/ppolicy_entity.ldif.erb"),
	         require     => [Execute_ldap['ldapadd-ppolicies-ou'], Package['ruby-ldap'], File['/usr/lib/ldap/check_password.so']];
	    }
    }

    $ldap_host_var      = '127.0.0.1:389'
    $ldap_use_ssl_var   = false
    $ldap_use_tls_var   = false
    $ldap_use_plain_var = ($ldap_use_ssl_var == false and $ldap_use_tls_var == false)
  }
  else {
    $ldap_host_var      = $ldap_host
    $ldap_use_ssl_var   = $ldap_use_ssl
    $ldap_use_tls_var   = $ldap_use_tls
    $ldap_use_plain_var = ($ldap_use_ssl_var == false and $ldap_use_tls_var == false)
  } # if - else
  
  

  if ($ldap_use_ssl) {
    exec { 'get-ldapcertificate':
      command => "echo -n | openssl s_client -connect ${ldap_host}:636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ldap-server.crt",
      unless  => "ls ldap-server.crt",
      cwd     => "/opt/shibboleth-idp/credentials",
      path    => ["/bin", "/usr/bin"],
      require => Shibboleth_install['execute_install'],
    }
  }

  file {
    '/opt/shibboleth-idp/conf/ldap.properties':
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0664',
      content => template("shib2idp/ldap.properties.erb"),
      require => Shibboleth_install['execute_install'];
      
    '/opt/shibboleth-idp/conf/authn/jaas.config':
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0664',
      content => template("shib2idp/jaas.config.erb"),
      require => Shibboleth_install['execute_install'];
      
    '/opt/shibboleth-idp/conf/authn/password-authn-config.xml':
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0664',
      source  => "puppet:///modules/shib2idp/password-authn-config.xml",
      require => Shibboleth_install['execute_install'];

    "/var/lib/${curtomcat}/common/mysql-connector-java.jar":
      ensure  => 'link',
      target  => '/usr/share/java/mysql-connector-java.jar',
      require => Class['tomcat', 'mysql::bindings::java'];

    "/opt/shibboleth-idp/bin/lib/mysql-connector-java.jar":
      ensure  => 'link',
      target  => '/usr/share/java/mysql-connector-java.jar',
      require => [Shibboleth_install['execute_install'], Class['mysql::bindings::java']];
  }
  
  download_file { "/var/lib/${curtomcat}/common/jstl-1.2.jar":
    url             => "https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar",
    require => Class['tomcat', 'mysql::bindings::java'],
  }
  
  mysql_database { ['userdb', 'storageservice']:
    ensure  => 'present',
    require => Class['mysql::server'],
  }

  execute_mysql {
    'userdb-table-shibpid':
      user              => 'root',
      password          => $rootpw,
      dbname            => 'userdb',
      query_check_empty => 'SHOW TABLES LIKE "shibpid"',
      sql               => [join(['CREATE TABLE shibpid (',
                                  'localEntity VARCHAR(255) NOT NULL,',
                                  'peerEntity VARCHAR(255) NOT NULL,',
                                  'principalName VARCHAR(255) NOT NULL DEFAULT \'\',',
                                  'localId VARCHAR(255) NOT NULL,',
                                  'persistentId VARCHAR(255) NOT NULL,',
                                  'peerProvidedId VARCHAR(255) DEFAULT NULL,',
                                  'creationDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,',
                                  'deactivationDate TIMESTAMP NULL DEFAULT NULL,',
                                  'KEY persistentId (persistentId),',
                                  'KEY persistentId_2 (persistentId, deactivationDate),',
                                  'KEY localEntity (localEntity(16), peerEntity(16), localId),',
                                  'KEY localEntity_2 (localEntity(16), peerEntity(16), localId, deactivationDate)',
                                  ')'], ' ')],
      require           => [Package['ruby-mysql'], MySql_Database['userdb']];
  }
  
  $scope = $domain_name
  include "shib2idp::idp::attributes"
  if ($install_ldap) {
    file { '/etc/cron.daily/ldap-backup':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("shib2idp/monitoring/backup_ldap.erb"),
    }
  }

  file {
    "/etc/cron.daily/mysql-backup":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("shib2idp/monitoring/backup_mysql.erb");

    "/opt/shibboleth-idp/conf/attribute-resolver.xml":
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0664',
      content => template("shib2idp/attribute-resolver.xml.erb"),
      require => Shibboleth_install['execute_install'];
  }

  if ($test_federation_var == true){
    file {
      "/opt/shibboleth-idp/conf/IDEM-attribute-filter.xml":
        ensure  => absent,
        owner   => $curtomcat,
	      group   => $curtomcat,
	      mode    => '0664',
        require => Shibboleth_install['execute_install'],
    }
  }
  else {
    file {
      "/opt/shibboleth-idp/conf/IDEM-attribute-filter.xml":
        ensure  => present,
        owner   => $curtomcat,
	      group   => $curtomcat,
	      mode    => '0664',
        require => Shibboleth_install['execute_install'],
    }
  }
  
  file {
    "/opt/shibboleth-idp/conf/attribute-filter.xml":
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0664',
      source  => "puppet:///modules/shib2idp/attribute-filter.xml",
      require => Shibboleth_install['execute_install'];
  
    "/opt/shibboleth-idp/conf/services.xml":
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0664',
      content => template("shib2idp/services.xml.erb"),
      require => Shibboleth_install['execute_install'];
  
    "/opt/shibboleth-idp/conf/metadata-providers.xml":
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0664',
      content => template('shib2idp/metadata-providers.xml.erb'),
      require => Shibboleth_install['execute_install'];
      
    "/opt/shibboleth-idp/conf/global.xml":
      ensure  => present,
      owner   => $curtomcat,
      group   => $curtomcat,
      mode    => '0664',
      content => template('shib2idp/global.xml.erb'),
      require => Shibboleth_install['execute_install'];
  }

  idp_metadata { '/opt/shibboleth-idp/metadata/idp-metadata.xml':
    filecontent          => template('shib2idp/idp-metadata.xml.erb'),
    metadata             => $metadata_information,
    certfilename         => '/opt/shibboleth-idp/credentials/idp.crt',
    certfilename_sign    => '/opt/shibboleth-idp/credentials/idp-signing.crt',
    certfilename_encrypt => '/opt/shibboleth-idp/credentials/idp-encryption.crt',
    certfilename_back    => '/opt/shibboleth-idp/credentials/idp-backchannel.crt',
    require              => Shibboleth_install['execute_install'],
  }

  download_file { '/opt/shibboleth-idp/credentials/idem-metadata-signer.pem':
    url     => 'https://www.idem.garr.it/documenti/doc_download/321-idem-metadata-signer-2019',
    require => Shibboleth_install['execute_install'],
  }
  
  #@@file { "/etc/shibboleth/${hostname}-metadata.xml":
  #  content => $::idpmetadata,
  #  tag => "${hostname}-metadata",
  #}

}
