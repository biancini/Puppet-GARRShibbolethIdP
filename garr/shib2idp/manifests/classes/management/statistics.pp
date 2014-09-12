# == Class: shib2idp::management::statistics
#
# This class installs a log analysis tool to generate statistics on the IdP usage by the users and performs all monitoring tasks.
#
# Parameters:
# +rootpw+:: This parameters must contain the password of the user with root access.
# +idpfqdn+:: This parameters must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::management::statistics (
  $rootpw          = 'ldappassword', 
  $idpfqdn         = 'puppetclient.example.com',
  $test_federation = true,
) {

  $dbuser   = "statistics"
  $dbpasswd = $rootpw
  $dbname   = "statistics"

  package { ['python-mysqldb', 'php5-mysql']: ensure => present, }

  mysql::db { $dbname:
    user     => $dbuser,
    password => $rootpw,
    host     => 'localhost',
    grant    => ['ALL'],
  }

  execute_mysql {
    "${dbname}-table-logins":
      user              => $dbuser,
      password          => $rootpw,
      dbname            => $dbname,
      query_check_empty => 'SHOW TABLES LIKE "logins"',
      sql               => [join(['CREATE TABLE logins (',
                                  'idp varchar(255) NOT NULL,',
                                  'data date NOT NULL,',
                                  'sp varchar(255) NOT NULL,',
                                  'user varchar(127) NOT NULL,',
                                  'logins int(11) DEFAULT NULL,',
                                  'PRIMARY KEY (idp,data,sp,user)',
                                  ') ENGINE=MyISAM DEFAULT CHARSET=latin1'], ' ')],
      require           => [Package['ruby-mysql'], MySql::Db[$dbname]];

    "${dbname}-table-sps":
      user              => $dbuser,
      password          => $rootpw,
      dbname            => $dbname,
      query_check_empty => 'SHOW TABLES LIKE "sps"',
      sql               => [join(['CREATE TABLE sps (',
                                  'sp varchar(255) NOT NULL,',
                                  'name varchar(255) DEFAULT NULL,',
                                  'PRIMARY KEY (sp)',
                                  ')'], ' ')],
      require           => [Package['ruby-mysql'], MySql::Db[$dbname]];
  }

  define process_file ($filename = $title, $dirpath, $content = undef, $srcpath = undef) {
    if ($content) {
      file { $filename:
        path    => "${dirpath}/${filename}",
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => $content;
      }
    } else {
        file { $filename:
          path   => "${dirpath}/${filename}",
          ensure => present,
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => "puppet:///modules/shib2idp/${srcpath}/${filename}",
        }
      }
  }

  $stats_installdir = '/root/loganalysis'

  file {
    $stats_installdir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
      
    "${stats_installdir}/logs":
      ensure  => link,
      target  => "/opt/shibboleth-idp/logs",
      require => File[$stats_installdir];
  }
  
  if ($test_federation) {
    file { 'idem-test-metadata-sha256.xml':
      path    => "${stats_installdir}/idem-test-metadata-sha256.xml",
      ensure  => link,
      target  => "/opt/shibboleth-idp/metadata/idem-test-metadata-sha256.xml",
      require => File[$stats_installdir],
    }
  } else {
    file { 'edugain2idem-metadata-sha256.xml':
      path    => "${stats_installdir}/edugain2idem-metadata-sha256.xml",
      ensure  => link,
      target  => "/opt/shibboleth-idp/metadata/edugain2idem-metadata-sha256.xml",
      require => File[$stats_installdir],
    }
  }

  process_file {
    'dbanalysis.py':
      dirpath => $stats_installdir,
      content => template("shib2idp/statistics/dbanalysis.erb"),
      require => File[$stats_installdir];

    'IDProvider.conf.php':
      dirpath => $stats_installdir,
      content => template("shib2idp/statistics/IDProvider.conf.erb"),
      require => File[$stats_installdir];

    'insertSP.php':
      dirpath => $stats_installdir,
      content => template("shib2idp/statistics/insertSP.erb"),
      require => File[$stats_installdir];

    ['config.php','functions.php','IDProvider.metadata.php','loganalysis.py','questionario.py','readMetadata.php','SProvider.conf.php','SProvider.metadata.php']:
      dirpath => $stats_installdir,
      srcpath => "statistics",
      require => File[$stats_installdir];
  }

  file { '/var/www/statistics':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755';
  }

  process_file {
    'db.php':
      dirpath => '/var/www/statistics',
      content => template("shib2idp/statistics/www/db.erb"),
      require => File['/var/www/statistics'];

    ['detailed.php','index.php','reset.css','shibboleth.png','stile.css']:
      dirpath => '/var/www/statistics',
      srcpath => "statistics/www",
      require => Process_file['db.php'];
  }

  file { '/etc/cron.daily/idp-loganalysis':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => join(['#!/bin/sh',
                     'cd /root/loganalysis',
                     '',
                     'php readMetadata.php',
                     'php insertSP.php',
                     '',
                     'python dbanalysis.py /opt/shibboleth-idp/logs/idp-audit*.log',
                     '#python dbanalysis.py /var/log/shib-idp-audit*.log',], "\n"),
    require => [Process_file['readMetadata.php', 'insertSP.php', 'dbanalysis.py'], Package['python-mysqldb', 'php5-mysql']],
  }

  file {
    "/etc/apache2/sites-available/statistics":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => join(['Alias /statistics /var/www/statistics',
                       '',
                       '<Directory /var/www/statistics>',
                       '        DirectoryIndex index.php',
                       '        Order Allow,Deny',
                       '        Allow from all',
                       '</Directory>'], "\n");

    "/etc/apache2/sites-enabled/statistics":
      ensure  => link,
      target  => "/etc/apache2/sites-available/statistics",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File["/etc/apache2/sites-available/statistics"],
      notify  => Exec['statistics-apache-reload'],
  }

  exec { 'statistics-apache-reload':
    command     => "/usr/sbin/service apache2 reload",
    refreshonly => true,
  }
}
