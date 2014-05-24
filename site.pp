node 'puppetclient.mib.garr.it' {
  idpfirewall::firewall { "${hostname}-firewall": 
      iptables_enable_network => undef,
  }

  $hostfqdn                = 'puppetclient.mib.garr.it'
  $keystorepassword        = 'puppetpassword'
  $mailto                  = 'admin.idp@mib.garr.it'
  $nagiosserver            = '10.0.0.165'

  shib2common::instance { "${hostname}-common":
    install_apache          => true,
    install_tomcat          => true,
    configure_admin         => true,
    tomcat_admin_password   => 'adminpassword',
    tomcat_manager_password => 'managerpassword',
    hostfqdn                => $hostfqdn,
    keystorepassword        => $keystorepassword,
    mailto                  => $mailto,
    nagiosserver            => $nagiosserver,
  }

  shib2idp::instance { "${hostname}-idp":
    metadata_information    => {
      'en'                => {
        'orgDisplayName'         => 'Test IdP for IdP in the cloud project',
        'communityDesc'          => 'GARR Research&amp;Development',
        'orgUrl'                 => 'http://www.garr.it/',
        'privacyPage'            => 'http://www.garr.it/',
        'nameOrg'                => 'Consortium GARR',
        'idpInfoUrl'             => 'https://puppetclient.mib.garr.it/idp/info.html',
        'url_LogoOrg-32x32'      => 'https://puppetclient.mib.garr.it/idp/images/logoEnte-32x32_en.png',
        'url_LogoOrg-160x120'    => 'https://puppetclient.mib.garr.it/idp/images/logoEnte-160x120_en.png',
      },
      'it'                => {
        'orgDisplayName'         => 'Test IdP for IdP in the cloud project',
        'communityDesc'          => 'GARR Research&amp;Development',
        'orgUrl'                 => 'http://www.garr.it/',
        'privacyPage'            => 'http://www.garr.it/',
        'nameOrg'                => 'Consortium GARR',
        'idpInfoUrl'             => 'https://puppetclient.mib.garr.it/idp/info.html',
        'url_LogoOrg-32x32'      => 'https://puppetclient.mib.garr.it/idp/images/logoEnte-32x32_it.png',
        'url_LogoOrg-160x120'    => 'https://puppetclient.mib.garr.it/idp/images/logoEnte-160x120_it.png',
      },
      'technicalEmail'             => 'mailto:support@puppetclient.mib.garr.it',
      'technicalIDPadminGivenName' => 'GivenName',
      'technicalIDPadminSurName'   => 'SurName',
      'technicalIDPadminTelephone' => '0200000000',
      'registrationInstant'        => '2013-06-27T12:00:00Z',
    },
    idpfqdn                      => $hostfqdn,
    keystorepassword             => $keystorepassword,
    mailto                       => $mailto,
    shibbolethversion            => '2.4.0',
    install_uapprove             => true,
    install_ldap                 => true,
    domain_name                  => 'mib.garr.it',
    basedn                       => 'dc=mib,dc=garr,dc=it',
    rootdn                       => 'cn=admin',
    rootpw                       => 'ldappassword',
    rootldappw                   => 'ldappassword',
    ldap_host                    => undef,
    ldap_use_ssl                 => undef,
    ldap_use_tls                 => undef,
    logserver                    => '10.0.0.165',
    nagiosserver                 => $nagiosserver,
    collectdserver               => '10.0.0.165',
    sambadomain                  => 'IDP-IN-THE-CLOUD',
    test_federation              => true,
    custom_styles                => true,
    first_install                => true,
    phpldap_easy_insert          => true,
    uapprove_version             => '2.5.0',
  }

  shib2ds::instance { "${hostname}-ds":
    shibbolethdsversion      => '1.2.1',
    federation_name          => 'GARR Milano Laboratorio',
    test_federation          => true,
    technicalEmail           => 'admin.idp@mib.garr.it',
    technicalGivenName       => 'GivenName',
    technicalSurName         => 'SurName',
    dsfqdn                   => $hostfqdn,
  }
}

node 'sp-test1.mib.garr.it' {
  $hostfqdn                = 'sp-test1.mib.garr.it'
  $keystorepassword        = 'puppetpassword'
  $mailto                  = 'admin.idp@mib.garr.it'
  $nagiosserver            = '10.0.0.165'

  shib2common::instance { "${hostname}-common":
    install_apache          => true,
    install_tomcat          => false,
    configure_admin         => false,
    tomcat_admin_password   => '',
    tomcat_manager_password => '',
    hostfqdn                => $hostfqdn,
    keystorepassword        => $keystorepassword,
    mailto                  => $mailto,
    nagiosserver            => $nagiosserver,
  }

  shib2sp::instance { "${hostname}-sp":
    metadata_information    => {
      'en'                => {
        'orgDisplayName'         => 'Test SP for IdP in the cloud project',
        'communityDesc'          => 'GARR Research&amp;Development',
        'orgUrl'                 => 'http://www.garr.it/',
        'nameOrg'                => 'Consortium GARR',
	'nameService'            => 'Test SP',
        'url_LogoOrg-32x32'      => 'https://puppetclient.mib.garr.it/idp/images/logoEnte-32x32_en.png',
        'url_LogoOrg-160x120'    => 'https://puppetclient.mib.garr.it/idp/images/logoEnte-160x120_en.png',
      },
      'it'                => {
        'orgDisplayName'         => 'Test SP for IdP in the cloud project',
        'communityDesc'          => 'GARR Research&amp;Development',
        'orgUrl'                 => 'http://www.garr.it/',
        'privacyPage'            => 'http://www.garr.it/',
        'nameOrg'                => 'Consortium GARR',
	'nameService'            => 'SP di test',
        'url_LogoOrg-32x32'      => 'https://puppetclient.mib.garr.it/idp/images/logoEnte-32x32_it.png',
        'url_LogoOrg-160x120'    => 'https://puppetclient.mib.garr.it/idp/images/logoEnte-160x120_it.png',
      },
      'technicalEmail'             => 'mailto:support@puppetclient.mib.garr.it',
      'technicalIDPadminGivenName' => 'GivenName',
      'technicalIDPadminSurName'   => 'SurName',
      'technicalIDPadminTelephone' => '',
      'attributes'                 => [
        {
          'oid'          => 'urn:oid:1.3.6.1.4.1.5923.1.1.1.6',
          'friendlyName' => 'eppn',
          'required'     => true,
        },
        {
          'oid'          => 'urn:oid:0.9.2342.19200300.100.1.3',
          'friendlyName' => 'mail',
          'required'     => true,
        },
        {
          'oid'          => 'urn:oid:2.5.4.10',
          'friendlyName' => 'o',
          'required'     => true,
        },
        {
          'oid'          => 'urn:oid:2.5.4.3',
          'friendlyName' => 'cn',
          'required'     => true,
        },
        {
          'oid'          => 'urn:oid:2.5.4.42',
          'friendlyName' => 'givenName',
          'required'     => true,
        },
      ],
    },
  }
}

node 'registry.mib.garr.it' {
  idpfirewall::firewall { "${hostname}-firewall": 
      iptables_enable_network => undef,
  }

  $hostfqdn                = 'registry.mib.garr.it'
  $keystorepassword        = 'puppetpassword'
  $mailto                  = 'admin.idp@mib.garr.it'
  $nagiosserver            = '10.0.0.165'

  shib2common::instance { "${hostname}-common":
    install_apache          => true,
    install_tomcat          => false,
    configure_admin         => false,
    hostfqdn                => $hostfqdn,
    mailto                  => $mailto,
    nagiosserver            => $nagiosserver,
  }

  shib2sp::instance { "${hostname}-sp":
    metadata_information    => {
      'en'                => {
        'orgDisplayName'         => 'Test SP for Jagger resource registry',
        'communityDesc'          => 'GARR Research&amp;Development',
        'orgUrl'                 => 'http://www.garr.it/',
        'nameOrg'                => 'Consortium GARR',
	'nameService'            => 'Jagger',
        'url_LogoOrg-32x32'      => 'https://registry.mib.garr.it/idp/images/logoEnte-32x32_en.png',
        'url_LogoOrg-160x120'    => 'https://registry.mib.garr.it/idp/images/logoEnte-160x120_en.png',
      },
      'it'                => {
        'orgDisplayName'         => 'SP di test per il resource registry Jagger',
        'communityDesc'          => 'GARR Research&amp;Development',
        'orgUrl'                 => 'http://www.garr.it/',
        'privacyPage'            => 'http://www.garr.it/',
        'nameOrg'                => 'Consortium GARR',
	'nameService'            => 'Jagger',
        'url_LogoOrg-32x32'      => 'https://registry.mib.garr.it/idp/images/logoEnte-32x32_it.png',
        'url_LogoOrg-160x120'    => 'https://registry.mib.garr.it/idp/images/logoEnte-160x120_it.png',
      },
      'technicalEmail'             => 'mailto:support@registry.mib.garr.it',
      'technicalIDPadminGivenName' => 'GivenName',
      'technicalIDPadminSurName'   => 'SurName',
      'technicalIDPadminTelephone' => '',
      'attributes'                 => [
        {
          'oid'          => 'urn:oid:1.3.6.1.4.1.5923.1.1.1.6',
          'friendlyName' => 'eppn',
          'required'     => true,
        },
        {
          'oid'          => 'urn:oid:2.5.4.42',
          'friendlyName' => 'givenName',
          'required'     => true,
        },
        {
          'oid'          => 'urn:oid:0.9.2342.19200300.100.1.3',
          'friendlyName' => 'mail',
          'required'     => true,
        },
        {
          'oid'          => 'urn:oid:2.5.4.4',
          'friendlyName' => 'sn',
          'required'     => true,
        },
        {
          'oid'          => 'urn:oid:1.3.6.1.4.1.5923.1.1.1.10',
          'friendlyName' => 'persistent-id',
          'required'     => true,
        },
      ],
    },
    session_initiator           => {
      'id'        => 'DS',
      'location'  => '/DS',
      'url'       => "https://${fqdn}/rr3/eds",
    },
    apache_doc_root => '/opt',
  }

  jagger::instance { "${hostname}-rr":
    rootpw                 => 'ciaoidem',
    rr3password            => 'ciaorr3',
    gearmand_version       => undef,
    install_signer         => true,
    logo_url               => 'https://www.idem.garr.it/documenti/doc_download/66-logo-idem-120-x-70',
    federation_name        => 'IDEM',
    jagger_password        => 'i7ryztaqlechgehcs5t7m5iy1ym9xxd4',
    support_mailto         => 'andrea@mib.garr.it',
    registration_authority => 'http://www.idem.garr.it/',
    federation_latitude    => '41.8929163',
    federation_longitude   => '12.4825199',
    telephone              => '+39 02 123456',
    app_environment        => undef,
  }
}
