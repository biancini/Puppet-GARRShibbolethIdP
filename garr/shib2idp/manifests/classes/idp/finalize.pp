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

  file { "/opt/shibboleth-idp/conf/handler.xml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/shib2idp/handler.xml",
    require => Shibboleth_install['execute_install'],
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
        require => Class['ldap::server::service'];

      "/etc/ldap/schema/eduperson-200412.ldif":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/eduperson-200412.ldif",
        require => Class['ldap::server::service'];

      "/etc/ldap/schema/schac-20110705-1.4.1.schema":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/schac-20110705-1.4.1.schema",
        require => Class['ldap::server::service'];

      "/etc/ldap/schema/schac-20110705-1.4.1.ldif":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/schac-20110705-1.4.1.ldif",
        require => Class['ldap::server::service'];

      "/etc/ldap/schema/ppolicy.ldif":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/ppolicy.ldif",
        require => Class['ldap::server::service'];

      "/etc/ldap/schema/ppolicy.schema":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/schema/ppolicy.schema",
        require => Class['ldap::server::service'];

      '/etc/cron.hourly/lockusers':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("shib2idp/monitoring/lockusers.py.erb"),
        require => Class['ldap::server::service'];
    }

    if($operatingsystem == 'Ubuntu' and $operatingsystemrelease == "14.04"){

     file{ "/usr/lib/ldap/check_password.so":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/ppolicy_modules/ldap-2-4-31-check_password.so",
        require => [Class['ldap::server::service'], File['/etc/ldap/schema/ppolicy.schema']],
      }
    }

    else{

     file{ "/usr/lib/ldap/check_password.so":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/ppolicy_modules/ldap-2-4-28-check_password.so",
        require => [Class['ldap::server::service'], File['/etc/ldap/schema/ppolicy.schema']],
      }
    }

    file_line {
      'eduperson-schema':
        ensure  => present,
        path    => '/etc/ldap/schema.conf',
        line    => 'include /etc/ldap/schema/eduperson-200412.schema',
        require => [Class['ldap::server::service'], File['/etc/ldap/schema/eduperson-200412.schema']],
        notify  => Exec['shib2-slapd-restart'];

      'schac-schema':
        ensure  => present,
        path    => '/etc/ldap/schema.conf',
        line    => 'include /etc/ldap/schema/schac-20110705-1.4.1.schema',
        require => [Class['ldap::server::service'], File['/etc/ldap/schema/schac-20110705-1.4.1.schema']],
        notify  => Exec['shib2-slapd-restart']
    }

    exec { 'shib2-slapd-restart':
      command     => "/usr/sbin/service slapd restart",
      require     => [Class['ldap::server::service'], File_line['eduperson-schema'], File_line['schac-schema']],
      refreshonly => true,
    }

    Exec['shib2-slapd-restart'] -> Execute_ldap['ldapadd-ppolicies-ou'] -> Execute_ldap['ldapadd-ppolicies-entity'] 

    if $rubyversion == "1.8.7" {
      execute_ldap { 'ldapadd-ppolicies-ou':
         rootdn      => "${rootdn},${basedn}",
         rootpw      => $rootldappw,
         ldif_search => "ou=policies,${basedn}",
         ldif        => template("shib2idp/ppolicy_ou.ldif.erb"),
         require     => [Class['ldap::server::service'], Package['libldap-ruby1.8']],
      }

      execute_ldap { 'ldapadd-ppolicies-entity':
         rootdn      => "${rootdn},${basedn}",
         rootpw      => $rootldappw,
         ldif_search => "cn=default,ou=policies,${basedn}",
         ldif        => template("shib2idp/ppolicy_entity.ldif.erb"),
         require     => [Class['ldap::server::service'], Package['libldap-ruby1.8'], File['/usr/lib/ldap/check_password.so']],
      }
    }
    # Ruby on Ubuntu 14.04 == 1.9.3
    else{
      execute_ldap { 'ldapadd-ppolicies-ou':
         rootdn      => "${rootdn},${basedn}",
         rootpw      => $rootldappw,
         ldif_search => "ou=policies,${basedn}",
         ldif        => template("shib2idp/ppolicy_ou.ldif.erb"),
         require     => [Class['ldap::server::service'], Package['ruby-ldap']],
      }

      execute_ldap { 'ldapadd-ppolicies-entity':
         rootdn      => "${rootdn},${basedn}",
         rootpw      => $rootldappw,
         ldif_search => "cn=default,ou=policies,${basedn}",
         ldif        => template("shib2idp/ppolicy_entity.ldif.erb"),
         require     => [Class['ldap::server::service'], Package['ruby-ldap'], File['/usr/lib/ldap/check_password.so']],
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

  file { "ldap-config-ssl":
    path    => '/opt/shibboleth-idp/conf/login.config',
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("shib2idp/login.config.erb"),
    require => Shibboleth_install['execute_install'],
  }

  file {
    "/var/lib/${curtomcat}/common/mysql-connector-java.jar":
      ensure  => 'link',
      target  => '/usr/share/java/mysql-connector-java.jar',
      require => Class['tomcat', 'mysql::bindings::java'];

    "/opt/shibboleth-idp/lib/mysql-connector-java.jar":
      ensure  => 'link',
      target  => '/usr/share/java/mysql-connector-java.jar',
      require => [Shibboleth_install['execute_install'], Class['mysql::bindings::java']];
  }
  
  mysql_database { 'userdb':
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
      require => Class['ldap::server::service'],
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
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/attribute-resolver.xml.erb"),
      require => Shibboleth_install['execute_install'];
  }

  if ($test_federation_var == true){
    file {
      "/opt/shibboleth-idp/conf/attribute-filter.xml":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/attribute-filter.xml",
        require => Shibboleth_install['execute_install'],
    } ->
    file {
      "/opt/shibboleth-idp/conf/IDEM-attribute-filter.xml":
        ensure => absent,
        owner  => $curtomcat,
        group  => $curtomcat,
        mode   => '0644',
        require => Shibboleth_install['execute_install'],
    } ->
    file {
      "/opt/shibboleth-idp/conf/service.xml":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/service.xml.erb"),
        require => Shibboleth_install['execute_install'],
    }
  }
  else{
    file {
      "/opt/shibboleth-idp/conf/IDEM-attribute-filter.xml":
        ensure  => present,
        owner   => $curtomcat,
        group   => $curtomcat,
        mode    => '0644',
        require => Shibboleth_install['execute_install'],
    } ->
    file {
      "/opt/shibboleth-idp/conf/attribute-filter.xml":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/attribute-filter.xml",
        require => Shibboleth_install['execute_install'],
    } ->
    file {
      "/opt/shibboleth-idp/conf/service.xml":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/service.xml.erb"),
        require => Shibboleth_install['execute_install'],
    }
  }

  file{
    "/opt/shibboleth-idp/conf/relying-party.xml":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('shib2idp/relying-party.xml.erb'),
      require => Shibboleth_install['execute_install'];
  }

  idp_metadata { '/opt/shibboleth-idp/metadata/idp-metadata.xml':
    filecontent  => template('shib2idp/idp-metadata.xml.erb'),
    metadata     => $metadata_information,
    certfilename => '/opt/shibboleth-idp/credentials/idp.crt',
    require      => Shibboleth_install['execute_install'],
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
