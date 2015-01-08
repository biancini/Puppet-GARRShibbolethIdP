# == Class: shib2idp::management::phpldap
#
# This class installs and configures the phpLDAPadmin tool to manipulate LDAP with a GUI interface.
#
# Parameters:
# +idpfqdn+:: This parameters must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
# +basedn+:: This parameters must contain the base DN of the LDAP server.
# +rootdn+:: This parameters must contain the CN for the user with root access to the LDAP server.
# +domain_name+:: This parameter permits to specify the domain name for the LDAP user database.
# +rootldappw+:: This parameters must contain the password of the user with root access to the LDAP server.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::management::phpldap (
  $metadata_information,
  $idpfqdn         = 'puppetclient.example.com',
  $basedn          = 'dc=example,dc=com',
  $rootdn          = 'cn=admin',
  $domain_name     = 'example.com',
  $rootldappw      = 'ldappassword',
  $easy_insert     = false,
  $technical_email = undef,
) {

  package {
    'php5-ldap':
      ensure => present;

    'phpldapadmin':
      ensure  => present,
      require => [Class['apache::mod::php'], Package['php5-ldap']];
  }

  class { 'apache::mod::php': }

  $ldap_host_var      = $shib2idp::idp::finalize::ldap_host_var
  $ldap_use_ssl_var   = $shib2idp::idp::finalize::ldap_use_ssl_var
  $ldap_use_tls_var   = $shib2idp::idp::finalize::ldap_use_tls_var
  $ldap_use_plain_var = $shib2idp::idp::finalize::ldap_use_plain_var
  $admin_username     = regsubst($rootdn, 'cn=', '')
  
  if ($technical_email) {
    $admin_email = $technical_email
  } else {
    $admin_email = "support@${domain_name}"
  }
  
  exec { 'add-user-htaccess':
    command => "htpasswd -bc .htpasswd ${admin_username} ${rootldappw}",
    unless  => "grep ${admin_username} .htpasswd",
    cwd     => "/usr/share/phpldapadmin",
    path    => ["/bin", "/usr/bin"],
    require => Package['phpldapadmin'],
  }
  
  file {
    "/etc/apache2/sites-available/phpldapadmin.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => join(['<Location /phpldapadmin>',
                       '    AuthUserFile /usr/share/phpldapadmin/.htpasswd',
                       '    AuthType Basic',
                       '    AuthName "Specify username and password"',
                       '    Require valid-user',
                       '</Location>',
                       '',
                       '<Location /pw/lockuser.php>',
                       '    AuthUserFile /usr/share/phpldapadmin/.htpasswd',
                       '    AuthType Basic',
                       '    AuthName "Specify username and password"',
                       '    Require valid-user',
                       '</Location>',
                       '',
                       '<Location /pw/action_lock.php>',
                       '    AuthUserFile /usr/share/phpldapadmin/.htpasswd',
                       '    AuthType Basic',
                       '    AuthName "Specify username and password"',
                       '    Require valid-user',
                       '</Location>',
                       '',
                       '<Location /phpldapadmin/images>',
											 '    Allow from all',
											 '    Satisfy any',
											 '</Location>',
											 '',
											 '<Location /phpldapadmin/css>',
											 '    Allow from all',
											 '    Satisfy any',
											 '</Location>',
											 '',
											 '<Location /phpldapadmin/js>',
											 '    Allow from all',
											 '    Satisfy any',
											 '</Location>',
											 '',
											 '<IfModule mod_alias.c>',
											 '    Alias /pw /usr/share/phpldapadmin/pw',
											 '</IfModule>',
											 '',
											 '<Directory /usr/share/phpldapadmin/pw/>',
											 '    DirectoryIndex changepw.php',
											 '    AllowOverride None',
											 '    Order allow,deny',
											 '    Allow from all',
											 '</Directory>'], "\n"),
      require => Exec['add-user-htaccess'];

    "/etc/apache2/sites-enabled/phpldapadmin.conf":
      ensure  => link,
      target  => "/etc/apache2/sites-available/phpldapadmin.conf",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File["/etc/apache2/sites-available/phpldapadmin.conf"];

    "/etc/apache2/conf.d/phpldapadmin.conf":
      ensure  => link,
      target  => "/etc/phpldapadmin/apache.conf",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File["/etc/apache2/sites-enabled/phpldapadmin.conf"],
      notify  => Exec['statistics-apache-reload'];
  }

  file {
    'phpldapadmin-config':
      path    => '/etc/phpldapadmin/config.php',
      ensure  => present,
      owner   => 'root',
      group   => 'www-data',
      mode    => '0640',
      content => template("shib2idp/monitoring/phpldapconfig.erb"),
      require => Package['phpldapadmin'];

    '/usr/share/phpldapadmin/htdocs/images/default/logo.png':
      ensure  => present,
      owner   => 'root',
      group   => 'www-data',
      mode    => '0640',
      source  => "puppet:///modules/shib2idp/monitoring/phpLDAPadmin-logo.png",
      require => Package['phpldapadmin'];

    '/usr/share/phpldapadmin/htdocs/images/default/logo-small.png':
      ensure  => present,
      owner   => 'root',
      group   => 'www-data',
      mode    => '0640',
      source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-160x120_en.png",
      require => Package['phpldapadmin'];
      
    'custom-homeJavascript':
      path    => '/usr/share/phpldapadmin/htdocs/js/homeJavascript.js',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/homeJavascript.js.erb"),
      require => Package['phpldapadmin'];
      
    'custom-formJavascript':
      path    => '/usr/share/phpldapadmin/htdocs/js/formJavascript.js',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/formJavascript.js.erb"),
      require => Package['phpldapadmin'];
      
    'jquery-javascript':
      path    => '/usr/share/phpldapadmin/htdocs/js/jquery-1.9.1.min.js',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/jquery-1.9.1.min.js",
      require => Package['phpldapadmin'];
      
    'jquery-javascript-map':
      path    => '/usr/share/phpldapadmin/htdocs/js/jquery.min.map',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/jquery.min.map",
      require => Package['phpldapadmin'];
     
    'jquery-ui-javascript':
      path    => '/usr/share/phpldapadmin/htdocs/js/jquery-ui-1.9.1.min.js',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/jquery-ui-1.9.1.min.js",
      require => Package['phpldapadmin'];
      
    'livevalidation-javascript':
      path    => '/usr/share/phpldapadmin/htdocs/js/livevalidation_standalone.compressed.js',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/livevalidation_standalone.compressed.js",
      require => Package['phpldapadmin'];
      
    'custom-css':
      path    => '/usr/share/phpldapadmin/htdocs/css/default/garr.css',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/garr.css",
      require => Package['phpldapadmin'];
      
    'province':
      path    => '/usr/share/phpldapadmin/lib/ripartizioni_regioni_province.csv',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/ripartizioni_regioni_province.csv",
      require => Package['phpldapadmin'];
    
    'checkValues':
      path    => '/usr/share/phpldapadmin/htdocs/checkValue.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/checkValue.erb"),
      require => Package['phpldapadmin'];
      
    'messages-ita':
      path    => '/usr/share/phpldapadmin/locale/it_IT/LC_MESSAGES/messages.po',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/messages_it.po.erb"),
      require => Package['phpldapadmin'],
      notify  => Exec['generate-locale-ita'];
      
    'management_index':
      path    => '/var/www/index.html',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/mgmt_index.erb"),
      require => [Package['phpldapadmin'], File['pwdir']];
  }
  
  exec { 'generate-locale-ita':
    command     => "msgfmt messages.po",
    cwd         => "/usr/share/phpldapadmin/locale/it_IT/LC_MESSAGES",
    path        => ["/bin", "/usr/bin"],
    refreshonly => true,
    require     => Package['gettext'],
  }
  
  if ($easy_insert == false) {
    file {
      'template-creation':
        path    => '/etc/phpldapadmin/templates/creation/custom_idpAccount.xml',
        ensure  => present,
        owner   => 'root',
        group   => 'www-data',
        mode    => '0640',
        content => template("shib2idp/monitoring/create_idpAccount.erb"),
        require => Package['phpldapadmin'];
    
      'template-modification':
        path    => '/etc/phpldapadmin/templates/modification/custom_idpAccount.xml',
        ensure  => present,
        owner   => 'root',
        group   => 'www-data',
        mode    => '0640',
        content => template("shib2idp/monitoring/modify_idpAccount.erb"),
        require => Package['phpldapadmin'];
     }
  }
  else {
    file {
      'template-creation':
        path    => '/etc/phpldapadmin/templates/creation/custom_idpAccount.xml',
        ensure  => present,
        owner   => 'root',
        group   => 'www-data',
        mode    => '0640',
        content => template("shib2idp/monitoring/create_idpAccount_easy.erb"),
        require => Package['phpldapadmin'];
    
      'template-modification':
        path    => '/etc/phpldapadmin/templates/modification/custom_idpAccount.xml',
        ensure  => present,
        owner   => 'root',
        group   => 'www-data',
        mode    => '0640',
        content => template("shib2idp/monitoring/modify_idpAccount_easy.erb"),
        require => Package['phpldapadmin'];
     }
  }
    
  file { 
    'pwdir':
      path    => '/usr/share/phpldapadmin/pw',
      ensure  => directory,
      purge   => false,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => Package['phpldapadmin'];
      
    'pw_files':
      path    => '/usr/share/phpldapadmin/pw/files',
      ensure  => directory,
      purge   => false,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => [Package['phpldapadmin'], File['pwdir']];
            
    'changepw':
      path    => '/usr/share/phpldapadmin/pw/changepw.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/changepw.erb"),
      require => [Package['phpldapadmin'], File['pwdir']];

    'action_pw':
      path    => '/usr/share/phpldapadmin/pw/action_pw.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/action_pw.php",
      require => [Package['phpldapadmin'], File['pwdir']];
      
    'retrievepw':
      path    => '/usr/share/phpldapadmin/pw/retrievepw.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/retrievepw.erb"),
      require => [Package['phpldapadmin'], File['pwdir']];
      
    'lockuser':
      path    => '/usr/share/phpldapadmin/pw/lockuser.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/lockuser.erb"),
      require => [Package['phpldapadmin'], File['pwdir']];

    'action_lock':
      path    => '/usr/share/phpldapadmin/pw/action_lock.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2idp/monitoring/action_lock.erb"),
      require => [Package['phpldapadmin'], File['pwdir']];
  }

  if ($operatingsystem == 'Ubuntu' and $operatingsystemmajrelease == '14.04'){

      exec{ 'modify-TemplateRenderOrig1': 
         command => "sed -i -e's/password_hash/password_hash_custom/' TemplateRenderOrig.php",
         unless  => "grep 'password_hash_custom' TemplateRenderOrig.php",
         cwd     => "/usr/share/phpldapadmin/lib",
         path    => ["/bin", "/usr/bin"],
         require => Exec['rename-TemplateRender'];
      }
  }
  
  exec {
    'rename-TemplateRender':
      command => "mv TemplateRender.php TemplateRenderOrig.php",
      unless  => "ls TemplateRenderOrig.php",
      cwd     => "/usr/share/phpldapadmin/lib",
      path    => ["/bin", "/usr/bin"],
      require => Package['phpldapadmin'];
      
    'modify-TemplateRenderOrig':
      command => "sed -i -e's/class TemplateRender extends PageRender/class TemplateRenderOrig extends PageRender/' TemplateRenderOrig.php",
      unless  => "grep 'class TemplateRenderOrig extends PageRender' TemplateRenderOrig.php",
      cwd     => "/usr/share/phpldapadmin/lib",
      path    => ["/bin", "/usr/bin"],
      require => Exec['rename-TemplateRender'];
      
    'rename-Template':
      command => "mv Template.php TemplateOrig.php",
      unless  => "ls TemplateOrig.php",
      cwd     => "/usr/share/phpldapadmin/lib",
      path    => ["/bin", "/usr/bin"],
      require => Package['phpldapadmin'];
      
    'modify-TemplateOrig':
      command => "sed -i -e's/class Template extends xmlTemplate/class TemplateOrig extends xmlTemplate/' TemplateOrig.php",
      unless  => "grep 'class TemplateOrig extends xmlTemplate' TemplateOrig.php",
      cwd     => "/usr/share/phpldapadmin/lib",
      path    => ["/bin", "/usr/bin"],
      require => Exec['rename-Template'];
      
    'rename-page':
      command => "mv page.php pageOrig.php",
      unless  => "ls pageOrig.php",
      cwd     => "/usr/share/phpldapadmin/lib",
      path    => ["/bin", "/usr/bin"],
      require => Package['phpldapadmin'];
      
    'modify-pageOrig':
      command => "sed -i -e's/class page/class pageOrig/' pageOrig.php",
      unless  => "grep 'class pageOrig' pageOrig.php",
      cwd     => "/usr/share/phpldapadmin/lib",
      path    => ["/bin", "/usr/bin"],
      require => Exec['rename-page'];
      
    'modify-create1':
      command => "sed -i -e\"s/\\\$request\\['template'\\]->getID()/\\\"custom_idpAccount\\:1\\\"/\" create.php",
      onlyif  => 'grep -F "$request[\'template\']->getID()" create.php',
      cwd     => "/usr/share/phpldapadmin/htdocs",
      path    => ["/bin", "/usr/bin"],
      require => Package['phpldapadmin'];
      
    'modify-create2':
      command => "sed -i -e\"s/default/\\\"custom_idpAccount\\:0\\\"/\" create.php",
      onlyif  => 'grep -F "default" create.php',
      cwd     => "/usr/share/phpldapadmin/htdocs",
      path    => ["/bin", "/usr/bin"],
      require => Package['phpldapadmin'];
      
    'modify-create3':
      command => "sed -i -e\"s/if (\\\$action_number == 1 || \\\$action_number == 2)$/\\\$redirect_url = 'cmd.php?cmd=template_engine\\&server_id=1\\&container=ou=people,dc=mib,dc=garr,dc=it';\\n\\tif (\\\$action_number == 1 || \\\$action_number == 2)/\" create.php",
      unless  => 'grep "\\$redirect_url = \'cmd.php?cmd=template_engine\\&server_id=1\\&container=ou=people,dc=mib,dc=garr,dc=it\';" create.php',
      cwd     => "/usr/share/phpldapadmin/htdocs",
      path    => ["/bin", "/usr/bin"],
      require => Package['phpldapadmin'];  
      
    'modify-htmltree':
      command => "sed -i -e's/return pretty_print_dn(\$entry->getDN());/return \"Users\";/' HTMLTree.php",
      onlyif  => 'grep -F \'return pretty_print_dn($entry->getDN());\' HTMLTree.php',
      cwd     => "/usr/share/phpldapadmin/lib",
      path    => ["/bin", "/usr/bin"],
      require => Package['phpldapadmin'];
  }
  
  file {
    'new-TemplateRender':
      path    => '/usr/share/phpldapadmin/lib/TemplateRender.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/TemplateRender.php",
      require => [Exec['modify-TemplateRenderOrig'], File['custom-homeJavascript', 'custom-formJavascript', 'jquery-javascript', 'livevalidation-javascript']];
      
    'new-Template':
      path    => '/usr/share/phpldapadmin/lib/Template.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/Template.php",
      require => [Exec['modify-TemplateOrig'], File['custom-homeJavascript', 'custom-formJavascript', 'jquery-javascript', 'livevalidation-javascript']];
      
    'new-page':
      path    => '/usr/share/phpldapadmin/lib/page.php',
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/shib2idp/monitoring/page.php",
      require => [Exec['modify-pageOrig'], File['custom-homeJavascript', 'custom-formJavascript', 'jquery-javascript', 'livevalidation-javascript']];
  }

  if $operatingsystem == 'Ubuntu' {
    exec { 'add-italian-locale':
      command => "locale-gen it_IT.UTF-8",
      unless  => "locale -a | grep it_IT.utf8",
      path    => ["/bin", "/usr/bin", "/usr/sbin"],
    }
  }
  else {
	  exec {
	    'set-default-locale':
	      command => "echo -e 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections",
	      unless  => "debconf-get-selections | grep 'default_environment_locale.*select.*en_US.UTF-8'",
	      path    => ["/bin", "/usr/bin"],
	      notify  => Exec['reconfigure-locales'];
	
	    'install-italian-locale':
	      command => "echo -e 'locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8, it_IT.UTF-8 UTF-8' | debconf-set-selections",
	      unless  => "debconf-get-selections | grep 'locales_to_be_generated.*multiselect.*en_US.UTF-8 UTF-8, it_IT.UTF-8 UTF-8'",
	      path    => ["/bin", "/usr/bin"],
	      notify  => Exec['reconfigure-locales'];
	
	    'reconfigure-locales':
	      command     => "dpkg-reconfigure --priority=critical locales",
	      require     => Exec['set-default-locale', 'install-italian-locale'],
	      path        => ["/bin", "/usr/bin", "/usr/sbin"],
	      refreshonly => true;
	  }
  }
}
