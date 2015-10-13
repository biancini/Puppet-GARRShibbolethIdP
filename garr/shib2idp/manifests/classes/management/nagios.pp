# == Class: shib2idp::management::nagios
#
# This class installs the Nagios NRPE server on IdP and define his checks.
#
# Parameters:
# +nagiosserver+:: This parameter permits to specify a Nagios server, if it contains a value different from undef NRPE daemon will be installed and configured to accept connections from the specified Nagios server.
# +sambadomain+:: This parameter permits to specify the Samba domain name to be configured while installing Nagios.
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
class shib2idp::management::nagios (
  $nagiosserver     = undef,
  $sambadomain      = 'WORKGROUP',
  $idpfqdn          = 'puppetclient.example.com',
  $basedn           = 'dc=example,dc=com',
  $rootdn           = 'cn=admin',
  $rootpw           = 'ldappassword',
  $rootldappw       = 'ldappassword',) {
  # Configuration of Nagios NRPE server
  if ($nagiosserver) {
    $searchuser = "uid=malavolti,ou=people"

    exec { 'samba-domain':
      command => "/bin/echo -e 'samba-common  samba-common/workgroup  string  IDP-IN-THE-CLOUD' | debconf-set-selections",
      path    => ["/bin", "/usr/bin"],
      require => Package["debconf-utils"],
      unless  => "debconf-get-selections | grep 'samba-common.*samba-common/workgroup.*string.*IDP-IN-THE-CLOUD'",
    }

    package {
      'nagios-nrpe-server':
        ensure  => installed,
        require => [Package['debconf-utils'], Exec['samba-domain']];

      'sudo':
        ensure => installed;
        
      'python-mechanize':
        ensure => installed;
    }
    
    service { 'nagios-nrpe-server':
      enable  => true,
      ensure  => 'running',
      require => Package['nagios-nrpe-server'],
    }

    file_line { 'sudoers nrpe':
      ensure  => present,
      path    => '/etc/sudoers',
      line    => 'nagios    ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/',
      require => Package["sudo"],
    }

    augeas {
      'nrpe.cfg server':
        context => "/files/etc/nagios/nrpe.cfg",
        changes => ["set allowed_hosts 127.0.0.1,${nagiosserver}",],
        onlyif  => "match allowed_hosts[. =~ regexp(\".*${nagiosserver}.*\")] size == 0",
        require => Package['nagios-nrpe-server'];

      'nrpe.cfg timeout':
        context => "/files/etc/nagios/nrpe.cfg",
        changes => ["set command_timeout 600",],
        onlyif  => "match command_timeout[. =~ regexp(\"600\")] size == 0",
        require => Package['nagios-nrpe-server'];

      'nrpe.cfg command_prefix':
        context => "/files/etc/nagios/nrpe.cfg",
        changes => ["set command_prefix /usr/bin/sudo",],
        onlyif  => "match command_timeout[. =~ regexp(\"/usr/bin/sudo\")] size == 0",
        require => [File_line['sudoers nrpe'], Package['nagios-nrpe-server', 'sudo']];
    }
    
    $ldap_host = $shib2idp::idp::finalize::ldap_host_var
    $use_ssl   = $shib2idp::idp::finalize::ldap_use_ssl_var
    $use_tls   = $shib2idp::idp::finalize::ldap_use_tls_var
    $fs_device = 'vda1'
    
    $aacli_cmd = [ 
      "command[check_${fs_device}]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/${fs_device}",
      "command[check_login]=/usr/lib/nagios/plugins/check_login -l",
      "command[check_aacli]=/usr/lib/nagios/plugins/check_aacli",
      "command[check_cert]=/usr/lib/nagios/plugins/check_cert",
      "command[check_ldap]=/usr/lib/nagios/plugins/check_ldap -H \"${ldap_host}\" -b \"${basedn}\" -D \"${rootdn},${basedn}\" -P ${rootldappw} -3",
      "command[check_ldaps]=/usr/lib/nagios/plugins/check_ldaps -H \"${ldap_host}\" -b \"${basedn}\" -D \"${rootdn},${basedn}\" -P ${rootldappw} -3",
      "command[check_userdb]=/usr/lib/nagios/plugins/check_mysql_query -q \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'userdb'\" -d userdb -u root -p ${rootpw}",
      "command[check_uApprove]=/usr/lib/nagios/plugins/check_mysql_query -q \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'ustorageservice'\" -d storageservice -u root -p ${rootpw}",
      "command[check_phpldapadmin]=/usr/lib/nagios/plugins/check_http -H localhost --ssl --url=/phpldapadmin/ --authorization=admin:${rootldappw}",
      "command[check_ro_fs]=/usr/lib/nagios/plugins/check_ro_fs -p /",
      "command[check_ram]=/usr/lib/nagios/plugins/check_mem 20 1"]

    file {
      '/usr/lib/nagios/plugins/check_login':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("shib2idp/monitoring/check_login.erb"),
        require => Package["nagios-nrpe-server", "python-mechanize", "python-ldap"];

      '/usr/lib/nagios/plugins/check_aacli':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("shib2idp/monitoring/check_aacli.erb"),
        require => Package["nagios-nrpe-server"];

      '/usr/lib/nagios/plugins/check_cert':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("shib2idp/monitoring/check_cert.erb"),
        require => Package["nagios-nrpe-server"];
        
      '/usr/lib/nagios/plugins/check_mem':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        source  => "puppet:///modules/shib2idp/monitoring/check_mem",
        require => Package["nagios-nrpe-server"];
        
      '/usr/lib/nagios/plugins/check_ro_fs':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        source  => "puppet:///modules/shib2idp/monitoring/check_ro_fs",
        require => Package["nagios-nrpe-server"];

      '/etc/nagios/nrpe.d/idp.cfg':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => join($aacli_cmd, "\n"),
        require => File[
          '/usr/lib/nagios/plugins/check_login',
          '/usr/lib/nagios/plugins/check_aacli',
          '/usr/lib/nagios/plugins/check_cert',
          '/usr/lib/nagios/plugins/check_mem',
          '/usr/lib/nagios/plugins/check_ro_fs'],
        notify  => Service['nagios-nrpe-server'];
    }
  }

}
