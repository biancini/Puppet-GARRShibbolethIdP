# == Class: shib2idp::idp::configure
#
# This class executes the configure stage of the installation and configuration of the
# Shibboleth IdP on the Puppet agent machine.
#
# The configure operations are used to configure all Tomcat connectors and web applications
# to support Shibboleth IdP execution.
#
# Parameters:
# +idpfqdn+:: This parameters must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
# +keystorepassword+:: This parameter permits to specify the keystore password used to protect the keystore file on the IdP server.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::idp::configure (
  $idpfqdn          = undef, 
  $keystorepassword = undef,
) {
  # Verify that /etc/environment has the correct lines
  $idp_home = '/opt/shibboleth-idp'
  $curtomcat = $::tomcat::curtomcat

  file_line {
    'idp_environment_rule_1':
      ensure => present,
      path   => '/etc/environment',
      line   => "JAVA_ENDORSED_DIRS=/usr/share/${curtomcat}/endorsed";

    'idp_environment_rule_2':
      ensure => present,
      path   => '/etc/environment',
      line   => "IDP_HOME=${idp_home}";
  }

  file { "/etc/${curtomcat}/Catalina/localhost/idp.xml":
    ensure  => present,
    owner   => "${curtomcat}",
    group   => "${curtomcat}",
    mode    => '0644',
    content => template("shib2idp/idp.xml.erb"),
    require => [Shibboleth_install['execute_install'], Class['tomcat']],
  }

  # Configure Shibboleth IdP
  download_file { "${tomcat::tomcat_home}/lib/tomcat6-dta-ssl-1.0.0.jar": 
    url     => 'https://build.shibboleth.net/nexus/content/repositories/releases/edu/internet2/middleware/security/tomcat6/tomcat6-dta-ssl/1.0.0/tomcat6-dta-ssl-1.0.0.jar',
    require => Class['tomcat'],
  }

  augeas {
    "server.xml_connector_8009":
      context => "/files/etc/${curtomcat}/server.xml/Server/Service[#attribute/name = 'Catalina']",
      changes => [
        "set Connector[last()]/#attribute/port 8009",
        "set Connector[last()]/#attribute/protocol AJP/1.3",
        "set Connector[last()]/#attribute/enableLookups false",
        "set Connector[last()]/#attribute/address 127.0.0.1",
        "set Connector[last()]/#attribute/redirectPort 443",
      ],
      onlyif  => "get Connector/#attribute/port[../port = '8009'] == ''",
      require => Class['tomcat'];

    "tomcat_authbind":
      context => "/files/etc/default/${curtomcat}",
      changes => ["defvar authcomment *[. = 'AUTHBIND=no']", "ins AUTHBIND after \$authcomment", "set AUTHBIND yes",],
      onlyif  => "get AUTHBIND != 'yes'",
      require => Class['tomcat'];

    "tomcat_javahome":
      context => "/files/etc/default/${curtomcat}",
      changes => [
        "defvar javahome *[. =~ regexp('JAVA_HOME.*')]",
        "ins JAVA_HOME after \$javahome",
        "set JAVA_HOME ${shib2idp::prerequisites::java_home}",],
      onlyif  => "get JAVA_HOME != '${shib2idp::prerequisites::java_home}'",
      require => Class['tomcat'];

    "tomcat_javaopts":
      context => "/files/etc/default/${curtomcat}",
      changes => [
        "set JAVA_OPTS '${shib2idp::prerequisites::java_opts}'",],
      onlyif  => "get JAVA_OPTS != '${shib2idp::prerequisites::java_opts}'",
      require => Class['tomcat'];
      
    "catalinaproperties_endorsed":
      context => "/files/etc/${curtomcat}/catalina.properties",
      changes => [
        "set common.loader '\${catalina.base}/lib,\${catalina.base}/lib/*.jar,\${catalina.home}/lib,\${catalina.home}/lib/*.jar,/var/lib/${curtomcat}/common/classes,/var/lib/${curtomcat}/common/*.jar,/usr/share/${curtomcat}/endorsed/*.jar'",
      ],
      onlyif  => "get common.loader != '\${catalina.base}/lib,\${catalina.base}/lib/*.jar,\${catalina.home}/lib,\${catalina.home}/lib/*.jar,/var/lib/${curtomcat}/common/classes,/var/lib/${curtomcat}/common/*.jar,/usr/share/${curtomcat}/endorsed/*.jar'",
      require => Class['tomcat'];
  }

  add_security_provider { 'security-providers':
    javasecurity_file => "/usr/lib/jvm/${shib2common::java::params::java_dir_name}/jre/lib/security/java.security",
    providerclasses   => [
      'edu.internet2.middleware.shibboleth.DelegateToApplicationProvider',
      'edu.internet2.middleware.shibboleth.quickInstallIdp.AnyCertProvider'],
      require => Class['shib2common::java::package'],
  }
}
