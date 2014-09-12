# == Class: shib2idp::idp::uapprove
#
# This class executes installs the uapprove module into Shibboleth IdP on the Puppet agent machine.
#
# The unpack operations are used to download the Internet2 Shibboleth implementation
# from their repository and to unpack it in /usr/local/src folder.
#
# Parameters:
# +shibbolethversion+:: This parameter permits to specify the version of Shibboleth IdP to be downloaded from the Internet2 repositories. By default the 2.3.3 version will be downloaded.
# +install_uapprove+:: This parameter permits to specify if uApprove has to be installed on this IdP
# +rootldappw+:: This parameters must contain the password of the user with access to the MySQL server.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::idp::uapprove (
  $install_uapprove  = undef,
  $uapprove_version  = '2.5.0',
  $shibbolethversion = '2.4.0',
  $rootldappw        = 'ldappassword',
  $nagiosserver      = undef,
) {

  $shibbolethsrc = "/usr/local/src/shibboleth-identityprovider-${shibbolethversion}"

  case $uapprove_version {
   '2.4.1': { 
            download_file { "/usr/local/src/uApprove-${uapprove_version}":
               url     => "https://forge.switch.ch/redmine/attachments/download/646/uApprove-${uapprove_version}.zip",
               #url     => "http://${::pupmaster}/downloads/uApprove-${uapprove_version}.zip",
               extract => 'zip',
            }
   }
   '2.5.0': {
            download_file { "/usr/local/src/uApprove-${uapprove_version}":
               url     => "https://forge.switch.ch/redmine/attachments/download/1623/uApprove-${uapprove_version}.zip",
               #url     => "http://${::pupmaster}/downloads/uApprove-${uapprove_version}.zip",
               extract => 'zip',            
            }
   }
  }
   
  file { 
      "${shibbolethsrc}/src/main/webapp/uApprove":
         ensure  => 'present',
         require => Exec["mkdir -p ${shibbolethsrc}/src/main/webapp/uApprove"];

      "${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages":
         ensure  => 'present',
         require => Exec["mkdir -p ${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages"];
  }

  exec {
   "mkdir -p ${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages":
      path    => ["/bin"],
      creates => "${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages",
      require => Download_file["/usr/local/src/uApprove-${uapprove_version}"],
      notify  => Exec["mkdir -p ${shibbolethsrc}/src/main/webapp/uApprove"];
   
   "mkdir -p ${shibbolethsrc}/src/main/webapp/uApprove":
      path    => ["/bin"],
      creates => "${shibbolethsrc}/src/main/webapp/uApprove",
      require => Exec["mkdir -p ${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages"],
      notify => Exec[
    "rm -fv ${shibbolethsrc}/lib/uApprove-*.jar ${shibbolethsrc}/lib/spring-jdbc-*.jar ${shibbolethsrc}/lib/spring-tx-*.jar ${shibbolethsrc}/lib/mysql-connector-java-*.jar ${shibbolethsrc}/src/main/webapp/uApprove/* /opt/shibboleth-idp/conf/sql-statements.properties /opt/shibboleth-idp/conf/uApprove.*",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/manual/examples/messages/terms-of-use_it.properties ${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages/terms-of-use.properties",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/manual/examples/messages/attribute-release_it.properties ${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages/attribute-release.properties",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/lib/*.jar ${shibbolethsrc}/lib/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/lib/jdbc/*.jar ${shibbolethsrc}/lib/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/lib/jdbc/optional/mysql*.jar ${shibbolethsrc}/lib/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/manual/configuration/uApprove.* /opt/shibboleth-idp/conf/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/webapp/* ${shibbolethsrc}/src/main/webapp/uApprove/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/manual/storage/sql-statements.properties /opt/shibboleth-idp/conf/"
    ];

   ["rm -fv ${shibbolethsrc}/lib/uApprove-*.jar ${shibbolethsrc}/lib/spring-jdbc-*.jar ${shibbolethsrc}/lib/spring-tx-*.jar ${shibbolethsrc}/lib/mysql-connector-java-*.jar ${shibbolethsrc}/src/main/webapp/uApprove/* /opt/shibboleth-idp/conf/sql-statements.properties /opt/shibboleth-idp/conf/uApprove.*",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/manual/examples/messages/terms-of-use_it.properties ${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages/terms-of-use.properties",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/manual/examples/messages/attribute-release_it.properties ${shibbolethsrc}/src/main/webapp/WEB-INF/classes/uApprove/messages/attribute-release.properties",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/lib/*.jar ${shibbolethsrc}/lib/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/lib/jdbc/*.jar ${shibbolethsrc}/lib/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/lib/jdbc/optional/mysql*.jar ${shibbolethsrc}/lib/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/manual/configuration/uApprove.* /opt/shibboleth-idp/conf/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/webapp/* ${shibbolethsrc}/src/main/webapp/uApprove/",
    "cp -v /usr/local/src/uApprove-${uapprove_version}/manual/storage/sql-statements.properties /opt/shibboleth-idp/conf/"]:
      path    => ["/bin"],
      require => File["${shibbolethsrc}/src/main/webapp/uApprove"],
      refreshonly => true;
  }

  mysql::db { 'uApprove':
    user     => 'uApprove',
    password => $rootldappw,
    host     => 'localhost',
    grant    => ['ALL'],
  }

  execute_mysql {
    'uapprove-table-ToUAcceptance':
      user              => 'uApprove',
      password          => $rootldappw,
      dbname            => 'uApprove',
      query_check_empty => 'SHOW TABLES LIKE "ToUAcceptance"',
      sql               => [join(['CREATE TABLE ToUAcceptance (',
                                  'userId VARCHAR(104) NOT NULL,',
                                  'version VARCHAR(104) NOT NULL,',
                                  'fingerprint VARCHAR(256) NOT NULL,',
                                  'acceptanceDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,',
                                  'PRIMARY KEY (userId, version)',
                                  ')'], ' ')],
      require           => [Package['ruby-mysql'], MySql::Db['uApprove']];

    'uapprove-table-AttributeReleaseConsent':
      user              => 'uApprove',
      password          => $rootldappw,
      dbname            => 'uApprove',
      query_check_empty => 'SHOW TABLES LIKE "AttributeReleaseConsent"',
      sql               => [join(['CREATE TABLE AttributeReleaseConsent (',
                                  'userId VARCHAR(104) NOT NULL,',
                                  'relyingPartyId VARCHAR(204) NOT NULL,',
                                  'attributeId VARCHAR(104) NOT NULL,',
                                  'valuesHash VARCHAR(256) NOT NULL,',
                                  'consentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,',
                                  'PRIMARY KEY (userId, relyingPartyId,attributeId)',
                                  ')'], ' ')],
      require           => [Package['ruby-mysql'], MySql::Db['uApprove']];
  }

  augeas { 'uapprove-web.xml':
    context => "/files/usr/local/src/shibboleth-identityprovider/src/main/webapp/WEB-INF/web.xml",
    changes => [
      'set web-app/context-param/param-value/#text "$IDP_HOME$/conf/internal.xml; $IDP_HOME$/conf/service.xml; $IDP_HOME$/conf/uApprove.xml"',
      'ins #comment after web-app/*[last()]',
      'set web-app/#comment[last()] "uApprove Filter and Servlets"',
      'ins filter after web-app/*[last()]',
      'set web-app/filter[last()]/filter-name/#text uApprove',
      'set web-app/filter[last()]/filter-class/#text "ch.SWITCH.aai.uApprove.Intercepter"',
      'ins filter-mapping after web-app/*[last()]',
      'set web-app/filter-mapping[last()]/filter-name/#text uApprove',
      'set web-app/filter-mapping[last()]/url-pattern[last()+1]/#text "/profile/Shibboleth/SSO"',
      'set web-app/filter-mapping[last()]/url-pattern[last()+1]/#text "/profile/SAML1/SOAP/AttributeQuery"',
      'set web-app/filter-mapping[last()]/url-pattern[last()+1]/#text "/profile/SAML1/SOAP/ArtifactResolution"',
      'set web-app/filter-mapping[last()]/url-pattern[last()+1]/#text "/profile/SAML2/POST/SSO"',
      'set web-app/filter-mapping[last()]/url-pattern[last()+1]/#text "/profile/SAML2/POST-SimpleSign/SSO"',
      'set web-app/filter-mapping[last()]/url-pattern[last()+1]/#text "/profile/SAML2/Redirect/SSO"',
      'set web-app/filter-mapping[last()]/url-pattern[last()+1]/#text "/profile/SAML2/Unsolicited/SSO"',
      'set web-app/filter-mapping[last()]/url-pattern[last()+1]/#text "/Authn/UserPassword"',
      'ins servlet after web-app/*[last()]',
      'set web-app/servlet[last()]/servlet-name/#text "uApprove - Terms Of Use"',
      'set web-app/servlet[last()]/servlet-class/#text "ch.SWITCH.aai.uApprove.tou.ToUServlet"',
      'ins servlet-mapping after web-app/*[last()]',
      'set web-app/servlet-mapping[last()]/servlet-name/#text "uApprove - Terms Of Use"',
      'set web-app/servlet-mapping[last()]/url-pattern/#text "/uApprove/TermsOfUse"',
      'ins servlet after web-app/*[last()]',
      'set web-app/servlet[last()]/servlet-name/#text "uApprove - Attribute Release"',
      'set web-app/servlet[last()]/servlet-class/#text "ch.SWITCH.aai.uApprove.ar.AttributeReleaseServlet"',
      'ins servlet-mapping after web-app/*[last()]',
      'set web-app/servlet-mapping[last()]/servlet-name/#text "uApprove - Attribute Release"',
      'set web-app/servlet-mapping[last()]/url-pattern/#text "/uApprove/AttributeRelease"',],
    onlyif  => 'match web-app/context-param/param-value/#text[. =~ regexp(".*uApprove.xml.*")] size == 0',
    require => File['/usr/local/src/shibboleth-identityprovider'],
  }

  file { 
      "${shibbolethsrc}/src/main/webapp/uApprove/terms-of-use.html":
         ensure  => present,
         owner   => 'root',
         group   => 'root',
         mode    => '0644',
         source  => "puppet:///modules/shib2idp/tou/${hostname}-tou.html",
         require => File["${shibbolethsrc}/src/main/webapp/uApprove"];

      "${shibbolethsrc}/src/main/webapp/uApprove/federation-logo.png":
         ensure  => present,
         owner   => 'root',
         group   => 'root',
         mode    => '0644',
         source  => "puppet:///modules/shib2idp/styles/template/IDEM_logo.png",
         require => [Download_file["/usr/local/src/shibboleth-identityprovider-${shibbolethversion}"], Exec["cp -v /usr/local/src/uApprove-${uapprove_version}/webapp/* ${shibbolethsrc}/src/main/webapp/uApprove/"]];

      "${shibbolethsrc}/src/main/webapp/uApprove/logo.png":
         ensure  => present,
         owner   => 'root',         
         group   => 'root',         
         mode    => '0644',
         source  => "puppet:///modules/shib2idp/styles/${hostname}-logo-160x120_en.png",
         require => [Download_file["/usr/local/src/shibboleth-identityprovider-${shibbolethversion}"], Exec["cp -v /usr/local/src/uApprove-${uapprove_version}/webapp/* ${shibbolethsrc}/src/main/webapp/uApprove/"]];

      "${shibbolethsrc}/src/main/webapp/uApprove/styles.css":
         ensure  => present,
         owner   => 'root',
         group   => 'root',
         mode    => '0644',
         source  => "puppet:///modules/shib2idp/uapprove.css",
         require => [Download_file["/usr/local/src/shibboleth-identityprovider-${shibbolethversion}"], Exec["cp -v /usr/local/src/uApprove-${uapprove_version}/webapp/* ${shibbolethsrc}/src/main/webapp/uApprove/"]];
  }

}
