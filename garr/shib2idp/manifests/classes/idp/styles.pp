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
      file {
        "/usr/local/src/shibboleth-identity-provider/messages/authn-messages_${name}.properties":
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0664',
          content => template("shib2idp/styles/authn-messages_${name}.properties.erb"),
          require => File['/usr/local/src/shibboleth-identity-provider'];

        "/usr/local/src/shibboleth-identity-provider/messages/consent-messages_${name}.properties":
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0664',
          content => template("shib2idp/styles/consent-messages_${name}.properties.erb"),
          require => File['/usr/local/src/shibboleth-identity-provider'];

        "/usr/local/src/shibboleth-identity-provider/messages/error-messages_${name}.properties":
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0664',
          content => template("shib2idp/styles/error-messages_${name}.properties.erb"),
          require => File['/usr/local/src/shibboleth-identity-provider'];
      }
    }
  }

  if ($custom_styles) {
    # Install graphical customization of look&feel
    file {
      '/usr/local/src/shibboleth-identity-provider/webapp/images/IDEM_logo.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/template/IDEM_logo.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/webapp/images/itFlag.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/template/itaFlag.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];       

       '/usr/local/src/shibboleth-identity-provider/webapp/images/enFlag.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/template/engFlag.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/webapp/images/institutionLogo-32x32_it.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-32x32_it.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/images/institutionLogo-160x120_it.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-160x120_it.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/webapp/images/institutionLogo-32x32_en.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-32x32_en.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
       '/usr/local/src/shibboleth-identity-provider/webapp/images/institutionLogo-160x120_en.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-160x120_en.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];

       '/usr/local/src/shibboleth-identity-provider/webapp/images/error.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/template/error.png",
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/error-404.jsp':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/styles/error-404.jsp.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/error.jsp':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/styles/error.jsp.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/info.html':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/info.html.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/privacy.html':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/privacy.html.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
       
      '/usr/local/src/shibboleth-identity-provider/webapp/css/login.css':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-login.css",
        require => File['/usr/local/src/shibboleth-identity-provider'];

      "/usr/local/src/shibboleth-identity-provider/messages/authn-messages.properties":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/styles/authn-messages.properties.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
      
      "/usr/local/src/shibboleth-identity-provider/messages/consent-messages.properties":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/styles/consent-messages.properties.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
      
      "/usr/local/src/shibboleth-identity-provider/messages/error-messages.properties":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/styles/error-messages.properties.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/views/login.vm':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/styles/login.vm.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];
        
      '/usr/local/src/shibboleth-identity-provider/views/login-error.vm':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        content => template("shib2idp/styles/login-error.vm.erb"),
        require => File['/usr/local/src/shibboleth-identity-provider'];

      '/usr/local/src/shibboleth-identity-provider/system/conf/mvc-beans.xml':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        source  => "puppet:///modules/shib2idp/styles/mvc-beans.xml",
        require => File['/usr/local/src/shibboleth-identity-provider'];
    }
    
    $langs_array = keys($metadata_information)
    message_file { $langs_array: }
  }   
}
