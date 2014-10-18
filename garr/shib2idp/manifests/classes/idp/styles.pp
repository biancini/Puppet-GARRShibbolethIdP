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
  $install_uapprove = true,
  $custom_styles = false,
){
  if ($custom_styles) {
    # Install graphical customization of look&feel
    file {
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/images/IDEM_logo.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/template/IDEM_logo.png",
        require => File['/usr/local/src/shibboleth-identityprovider'];

      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/images/itaFlag.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/template/itaFlag.png",
        require => File['/usr/local/src/shibboleth-identityprovider'];       

       '/usr/local/src/shibboleth-identityprovider/src/main/webapp/images/engFlag.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/template/engFlag.png",
        require => File['/usr/local/src/shibboleth-identityprovider'];

      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/images/institutionLogo-32x32_it.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-32x32_it.png",
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/images/institutionLogo-160x120_it.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-160x120_it.png",
        require => File['/usr/local/src/shibboleth-identityprovider'];

      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/images/institutionLogo-32x32_en.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-32x32_en.png",
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
       '/usr/local/src/shibboleth-identityprovider/src/main/webapp/images/institutionLogo-160x120_en.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-160x120_en.png",
        require => File['/usr/local/src/shibboleth-identityprovider'];

       '/usr/local/src/shibboleth-identityprovider/src/main/webapp/images/error.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/template/error.png",
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/login.jsp':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/styles/login.jsp.erb"),
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/error-404.jsp':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/styles/error-404.jsp.erb"),
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/error.jsp':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/styles/error.jsp.erb"),
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/info.html':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/info.html.erb"),
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
#      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/help.html':
#        ensure  => present,
#        owner   => 'root',
#        group   => 'root',
#        mode    => '0644',
#        source  => "puppet:///modules/shib2idp/styles/template/help.html",
#        require => File['/usr/local/src/shibboleth-identityprovider'];
       
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/privacy.html':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/privacy.html.erb"),
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/login.css':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/${hostname}-login.css",
        require => File['/usr/local/src/shibboleth-identityprovider'];
       
      '/usr/local/src/shibboleth-identityprovider/src/main/webapp/login-error.jsp':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("shib2idp/styles/login-error.jsp.erb"),
        require => File['/usr/local/src/shibboleth-identityprovider'];

      "/usr/local/src/shibboleth-identityprovider/src/main/webapp/WEB-INF/classes/messages.properties":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///modules/shib2idp/styles/messages.properties",
        require => File['/usr/local/src/shibboleth-identityprovider'];
    }

    $metadata_information.each_pair do |$lang, $vals| {
      if ($lang != "en") {
        file { "/usr/local/src/shibboleth-identityprovider/src/main/webapp/WEB-INF/classes/messages_${lang}.properties":
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          source  => "puppet:///modules/shib2idp/styles/messages_${lang}.properties",
          require => File['/usr/local/src/shibboleth-identityprovider'],
        }
      }
    }
  }   
}
