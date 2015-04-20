# == Class: shib2idp::management::raptorica
#
# This class executes installs the Raptor ICA module to connect to IDEM Raptor.
#
# Parameters:
# +shibbolethversion+:: This parameter permits to specify the version of Shibboleth IdP to be downloaded from the Internet2 repositories. By default the 2.3.3 version will be downloaded.
# +rootldappw+:: This parameters must contain the password of the user with access to the MySQL server.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::management::raptorica (
  $jks_password         = undef,
  $metadata_information = undef,
) {
  
  package { 'alien': 
    ensure => installed,
  }
  
  download_file { '/opt/raptor-ica_1.1.2-2.1_all.rpm':
    url             => 'http://download.opensuse.org/repositories/home:/rhyssmith:/raptor/SLE_11/noarch/raptor-ica-1.2.1-1.1.noarch.rpm',
    execute_command => '/bin/rm -f /opt/raptor-ica_1.1.2-2.1_all.deb',
  }
  
  exec {
    'transform package to deb':
      command => 'alien --scripts raptor-ica_1.1.2-2.1_all.rpm',
      cwd     => '/opt',
      path    => ['/bin', '/usr/bin'],
      creates => '/opt/raptor-ica_1.2.1-2.1_all.deb',
      unless  => 'test -f /opt/raptor-ica_1.2.1-2.1_all.deb',
      require => [Package['alien'], Download_file['/opt/raptor-ica_1.1.2-2.1_all.rpm']];
        
    'generate keystore':
      command => "keytool -genkeypair -alias raptorica -keystore raptor-ica.jks -storepass ${jks_password} -keypass ${jks_password} -dname \"CN=${fqdn},ou=ICA,o=Raptor\" -validity 7300 -keyalg RSA -keysize 2048",
      cwd     => '/opt/raptor/ica/keys',
      path    => ['/bin', '/usr/bin'],
      creates => '/opt/raptor/ica/keys/raptor-ica.jks',
      unless  => 'test -f /opt/raptor/ica/keys/raptor-ica.jks',
      notify  => Service['raptoricad'];
      
    'extract public certificate':
      command => "keytool -export -alias raptorica -keystore raptor-ica.jks -storepass ${jks_password} -file raptor-ica-public.crt",
      cwd     => '/opt/raptor/ica/keys',
      path    => ['/bin', '/usr/bin'],
      creates => '/opt/raptor/ica/keys/raptor-ica-public.crt',
      unless  => 'test -f /opt/raptor/ica/keys/raptor-ica-public.crt',
      require => Exec['generate keystore'],
      notify  => Service['raptoricad'];
      
    'import MUA certificate':
      command => "keytool -import -noprompt -keystore authorised-keys.jks -storepass ${jks_password} -alias raptormua -file raptor-mua-public.crt",
      cwd     => '/opt/raptor/ica/keys',
      path    => ['/bin', '/usr/bin'],
      unless  => 'test -f /opt/raptor/ica/keys/authorised-keys.jks',
      creates => '/opt/raptor/ica/keys/authorised-keys.jks',
      require => File['/opt/raptor/ica/keys/raptor-mua-public.crt'],
      notify  => Service['raptoricad'];
      
    'lower log to ERROR':
      command => "sed -i s/INFO/ERROR/g logging.xml",
      cwd     => '/opt/raptor/ica/conf',
      path    => ['/bin', '/usr/bin'],
      onlyif  => 'grep INFO /opt/raptor/ica/conf/logging.xml',
      require => Package['raptor-ica'],
      notify  => Service['raptoricad'];
  }

  file {
    '/sbin/insserv':
      ensure  => 'link',
      target  => '/usr/lib/insserv/insserv';
      
    '/etc/init.d/raptoricad':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => 'puppet:///modules/shib2idp/monitoring/raptoricad',
      require => Package['raptor-ica'];
      
    '/opt/raptor/ica/conf/metadata.xml':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('shib2idp/monitoring/ica-metadata.xml.erb'),
      require => Package['raptor-ica'],
      notify  => Service['raptoricad'];

    '/opt/raptor/ica/conf/event-release.xml':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('shib2idp/monitoring/event-release.xml.erb'),
      require => Package['raptor-ica'],
      notify  => Service['raptoricad'];
      
    '/opt/raptor/ica/keys/raptor-mua-public.crt':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/shib2idp/monitoring/raptor-mua-public.crt';
  }
  
  package { 'raptor-ica':
    provider => dpkg,
    ensure   => latest,
    source   => '/opt/raptor-ica_1.2.1-2.1_all.deb',
    require  => [Exec['transform package to deb'], File['/sbin/insserv']],
  }
  
  service { 'raptoricad':
    enable     => true,
    ensure     => running,
    require    => File['/etc/init.d/raptoricad'],
  }
}
