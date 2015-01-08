# == Class: shib2idp::management::rsyslog
#
# This class configure 'rsyslog' remote logging on the IdP.
#
# Parameters:
# +logserver+:: This parameter permits to specify if the logs should be sent to a centralized log server. In case this variable is not undef, rsyslog will be configured to send the logs to the specified server.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::management::rsyslog (
  $logserver = undef,
) {
  if ($logserver) {
	  # Remote logging with rsyslog
	  file { '/etc/rsyslog.d/99-tomcat.conf':
	    ensure  => present,
	    owner   => 'root',
	    group   => 'root',
	    mode    => '0644',
	    content => template("shib2idp/99-tomcat.erb"),
	    notify => Exec['rsyslog'],
	  }
	
    exec { 'rsyslog':
      command     => "/usr/sbin/service rsyslog restart",
      #path       => ["/usr/sbin"],
      require     => File['/etc/rsyslog.d/99-tomcat.conf'],
      refreshonly => true,
    }
	
	  file { '/opt/shibboleth-idp/conf/logging.xml':
	    ensure  => present,
	    owner   => 'root',
	    group   => 'root',
	    mode    => '0644',
	    content  => template ("shib2idp/logging.xml.erb"),
	    require => [Shibboleth_install['execute_install'], File['/etc/rsyslog.d/99-tomcat.conf']];
	  }
  } else {
    file { 
      '/etc/rsyslog.d/99-tomcat.conf':
        ensure => absent;

      '/opt/shibboleth-idp/logs/shib-idp-process.log':
        ensure => absent;

      '/opt/shibboleth-idp/logs/shib-idp-access.log':
        ensure => absent;

      '/opt/shibboleth-idp/logs/shib-idp-audit.log':
        ensure => absent;
    }
  }
}
