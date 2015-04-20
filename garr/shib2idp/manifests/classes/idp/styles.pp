# == Class: shib2idp::idp::stili
#
# This class install the stiles for customizing the login page of the IdP. 
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::idp::styles(
  $install_ldap_var = undef,
  $metadata_information = undef,
  $custom_styles = false,
){

  define message_file() {
    if ($name != "en" and inline_template("<%= name.length %>") == "2") {
      file { "/usr/local/src/shibboleth-identity-provider/webapp/WEB-INF/classes/messages_${name}.properties":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/messages_${name}.properties",
        require => File['/usr/local/src/shibboleth-identity-provider/webapp/WEB-INF/classes'],
      }
    }
  }

  if ($custom_styles) {
    # Install graphical customization of look&feel
    file {
      '/usr/local/src/shibboleth-identity-provider/webapp/WEB-INF/classes':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/webapp/images/IDEM_logo.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/template/IDEM_logo.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/webapp/images/itFlag.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/template/itaFlag.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];       

       '/usr/local/src/shibboleth-identity-provider/webapp/images/enFlag.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/template/engFlag.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/webapp/images/institutionLogo-32x32_it.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-32x32_it.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/images/institutionLogo-160x120_it.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-160x120_it.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/webapp/images/institutionLogo-32x32_en.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-32x32_en.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
       '/usr/local/src/shibboleth-identity-provider/webapp/images/institutionLogo-160x120_en.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-160x120_en.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];

       '/usr/local/src/shibboleth-identity-provider/webapp/images/error.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/template/error.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/error-404.jsp':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/styles/error-404.jsp.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/error.jsp':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/styles/error.jsp.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/info.html':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/info.html.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/privacy.html':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/privacy.html.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/css/login.css':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-login.css",
        require => File['/usr/local/src/shibboleth-identity-provider'];

      "/usr/local/src/shibboleth-identity-provider/webapp/WEB-INF/classes/messages.properties":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/messages.properties",
        require => File['/usr/local/src/shibboleth-identity-provider/webapp/WEB-INF/classes'];
        
      '/usr/local/src/shibboleth-identity-provider/views/login.vm':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/styles/login.vm.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
        
      '/usr/local/src/shibboleth-identity-provider/messages/error-messages.properties':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/styles/login.vm.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
    }
    
    $langs_array = keys($metadata_information)
    message_file { $langs_array: }
  }   
}
