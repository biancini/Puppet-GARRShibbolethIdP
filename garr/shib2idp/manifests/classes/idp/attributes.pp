class shib2idp::idp::attributes() {
   $attribute_definition = {
      'surname' => {
         'langs' => {
            'en' => {
               'dispName' => "Surname",
               'dispDescr' => "Surname of a person",
            },
            'it' => {
               'dispName' => "Cognome",
               'dispDescr' => "Cognome di una persona",
            },
         },
         'id'                => "surname",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "sn",
         'saml1string'       => "urn:mace:dir:attribute-def:sn",
         'saml2string'       => "urn:oid:2.5.4.4",
         'friendlyName'      => "sn",
      },
      'givenName' => {
         'langs' => {
            'en' => {
               'dispName' => "Name",
               'dispDescr' => "Given name of a person",
            },
            'it' => {
               'dispName' => "Nome",
               'dispDescr' => "Nome proprio di una persona",
            },
         },
         'id'                => "givenName",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "givenName",
         'saml1string'       => "urn:mace:dir:attribute-def:givenName",
         'saml2string'       => "urn:oid:2.5.4.42",
         'friendlyName'      => "givenName",
      },
      'commonName' => {
         'langs' => {
            'en' => {
               'dispName' => "Given Name and Surname",
               'dispDescr' => "Given Name and Surname of a person",
            },
            'it' => {
               'dispName' => "Nome e Cognome",
               'dispDescr' => "Nome e Cognome di una persona",
            },
         },
         'id'                => "commonName",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "cn",
         'saml1string'       => "urn:mace:dir:attribute-def:cn",
         'saml2string'       => "urn:oid:2.5.4.3",
         'friendlyName'      => "cn",
      },
      'street' => {
         'langs' => {
            'en' => {
               'dispName' => "Postal Address",
               'dispDescr' => "Postal Address of a person",
            },
            'it' => {
               'dispName' => "Indirizzo Postale",
               'dispDescr' => "Indirizzo postale della residenza di una persona",
            },
         },
         'id'                => "street",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "street",
         'saml1string'       => "urn:mace:dir:attribute-def:street",
         'saml2string'       => "urn:oid:2.5.4.9",
         'friendlyName'      => "street",
      },
      'houseIdentifier' => {
         'langs' => {
            'en' => {
               'dispName' => "House Identifier",
               'dispDescr' => "A linquistic construct used to identify a particular building",
            },
            'it' => {
               'dispName' => "Identificativo della residenza",
               'dispDescr' => "Costrutto linguistico usato per identificare una particolare edificio",
            },
         },
         'id'                => "houseIdentifier",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "houseIdentifier",
         'saml1string'       => "urn:mace:dir:attribute-def:houseIdentifier",
         'saml2string'       => "urn:oid:2.5.4.51",
         'friendlyName'      => "houseIdentifier",
      },
      'locality' => {
         'langs' => {
            'en' => {
               'dispName' => "Locality",
               'dispDescr' => "Locality of a building",
            },
            'it' => {
               'dispName' => "Localit&agrave;",
               'dispDescr' => "Localit&agrave; di un edificio",
            },
         },
         'id'                => "locality",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "l",
         'saml1string'       => "urn:mace:dir:attribute-def:l",
         'saml2string'       => "urn:oid:2.5.4.7",
         'friendlyName'      => "l",
      },
      'postalCode' => {
         'langs' => {
            'en' => {
               'dispName' => "Postal Code",
               'dispDescr' => "Postal Code",
            },
            'it' => {
               'dispName' => "CAP",
               'dispDescr' => "Codice di avviamento postale",
            },
         },
         'id'                => "postalCode",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "postalCode",
         'saml1string'       => "urn:mace:dir:attribute-def:postalCode",
         'saml2string'       => "urn:oid:2.5.4.17",
         'friendlyName'      => "postalCode",
      },
      'stateOrProvinceName' => {
         'langs' => {
            'en' => {
               'dispName' => "State or Province",
               'dispDescr' => "Name of State or Province where a person live",
            },
            'it' => {
               'dispName' => "Stato o Provincia",
               'dispDescr' => "Nome dello Stato o della Provincia dove una persona abita",
            },
         },
         'id'                => "stateOrProvinceName",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "st",
         'saml1string'       => "urn:mace:dir:attribute-def:st",
         'saml2string'       => "urn:oid:2.5.4.8",
         'friendlyName'      => "st",
      },
      'telephoneNumber' => {
         'langs' => {
            'en' => {
               'dispName' => "Telephone Number",
               'dispDescr' => "Telephone Number",
            },
            'it' => {
               'dispName' => "Numero di Telefono",
               'dispDescr' => "Numero di telefono",
            },
         },
         'id'                => "telephoneNumber",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "telephoneNumber",
         'saml1string'       => "urn:mace:dir:attribute-def:telephoneNumber",
         'saml2string'       => "urn:oid:2.5.4.20",
         'friendlyName'      => "telephoneNumber",
      },
      'organizationName' => {
         'langs' => {
            'en' => {
               'dispName' => "Organization Name",
               'dispDescr' => "Name of an Organization",
            },
            'it' => {
               'dispName' => "Nome Organizzazione",
               'dispDescr' => "Nome dell'organizzazione",
            },
         },
         'id'                => "organizationName",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "o",
         'saml1string'       => "urn:mace:dir:attribute-def:o",
         'saml2string'       => "urn:oid:2.5.4.10",
         'friendlyName'      => "o",
      },
      'organizationalUnit' => {
         'langs' => {
            'en' => {
               'dispName' => "Organizational Unit",
               'dispDescr' => "Organizational Unit of an Organization",
            },
            'it' => {
               'dispName' => "Unit&agrave; organizzativa",
               'dispDescr' => "Unit&agrave; organizzativa dell'Organizzazione",
            },
         },
         'id'                => "organizationalUnit",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "ou",
         'saml1string'       => "urn:mace:dir:attribute-def:ou",
         'saml2string'       => "urn:oid:2.5.4.11",
         'friendlyName'      => "ou",
      },
      'email' => {
         'langs' => {
            'en' => {
               'dispName' => "E-mail",
               'dispDescr' => "E-Mail: Preferred address for e-mail to be sent to this person",
            },
            'it' => {
               'dispName' => "E-mail",
               'dispDescr' => "E-Mail: Iindirizzo e-mail preferito dall'utente",
            },
         },
         'id'                => "email",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "mail",
         'saml1string'       => "urn:mace:dir:attribute-def:mail",
         'saml2string'       => "urn:oid:0.9.2342.19200300.100.1.3",
         'friendlyName'      => "mail",
      },
      'displayName' => {
         'langs' => {
            'en' => {
               'dispName' => "Display name",
               'dispDescr' => "Preferred name of a person to be used when displaying entries",
            },
            'it' => {
               'dispName' => "Nome visualizzato",
               'dispDescr' => "Nome che una persona preferisce visualizzare",
            },
         },
         'id'                => "displayName",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "displayName",
         'saml1string'       => "urn:mace:dir:attribute-def:displayName",
         'saml2string'       => "urn:oid:2.16.840.1.113730.3.1.241",
         'friendlyName'      => "displayName",
      },
      'schacDateOfBirth' => {
         'langs' => {
            'en' => {
               'dispName' => "Date of Birth",
               'dispDescr' => "Date of birth of a person",
            },
            'it' => {
               'dispName' => "Data di Nascita",
               'dispDescr' => "Data di nascita di una persona",
            },
         },
         'id'                => "schacDateOfBirth",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "schacDateOfBirth",
         'saml1string'       => "urn:mace:terena.org:schac:attribute-def:schacDateOfBirth",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.25178.1.2.3",
         'friendlyName'      => "schacDateOfBirth",
      },
      'schacYearOfBirth' => {
         'langs' => {
            'en' => {
               'dispName' => "Year of Birth",
               'dispDescr' => "Year of birth of a person",
            },
            'it' => {
               'dispName' => "Anno di Nascita",
               'dispDescr' => "Anno di nascita di una persona",
            },
         },
         'id'                => "schacYearOfBirth",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "schacYearOfBirth",
         'saml1string'       => "urn:mace:terena.org:schac:attribute-def:schacYearOfBirth",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.25178.1.0.2.3",
         'friendlyName'      => "schacYearOfBirth",
      },
      'schacPlaceOfBirth' => {
         'langs' => {
            'en' => {
               'dispName' => "Place of Birth",
               'dispDescr' => "Place of birth of a person",
            },
            'it' => {
               'dispName' => "Luogo di Nascita",
               'dispDescr' => "Luogo di nascita di una persona",
            },
         },
         'id'                => "schacPlaceOfBirth",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "schacPlaceOfBirth",
         'saml1string'       => "urn:mace:terena.org:schac:attribute-def:schacPlaceOfBirth",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.25178.1.2.4",
         'friendlyName'      => "schacPlaceOfBirth",
      },
      'schacPersonalUniqueID' => {
         'langs' => {
            'en' => {
               'dispName' => "Personal Unique Identifier",
               'dispDescr' => "Unique identifier for the subject. Example: Fiscal Code",
            },
            'it' => {
               'dispName' => "Identificatore Univoco personale",
               'dispDescr' => "Identificativo personale univoco. Esempio: Codice Fiscale",
            },
         },
         'id'                => "schacPersonalUniqueID",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "schacPersonalUniqueID",
         'saml1string'       => "urn:mace:terena.org:schac:attribute-def:schacPersonalUniqueID",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.25178.1.2.15",
         'friendlyName'      => "schacPersonalUniqueID",
      },
      'schacPersonalPosition' => {
         'langs' => {
            'en' => {
               'dispName' => "Personal Position",
               'dispDescr' => "Position inside an institution",
            },
            'it' => {
               'dispName' => "Ruolo Ricoperto",
               'dispDescr' => "Ruolo ricoperto nell'istituzione",
            },
         },
         'id'                => "schacPersonalPosition",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "schacPersonalPosition",
         'saml1string'       => "urn:mace:terena.org:schac:attribute-def:schacPersonalPosition",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.25178.1.2.13",
         'friendlyName'      => "schacPersonalPosition",
      },
      'schacHomeOrganization' => {
         'langs' => {
            'en' => {
               'dispName' => "Home Organization Domain",
               'dispDescr' => "Domain name of the home organization",
            },
            'it' => {
               'dispName' => "Dominio Organizzazione",
               'dispDescr' => "Dominio dell'Organizzazione",
            },
         },
         'id'                => "schacHomeOrganization",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "schacHomeOrganization",
         'saml1string'       => "urn:mace:terena.org:schac:attribute-def:schacHomeOrganization",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.25178.1.2.9",
         'friendlyName'      => "schacHomeOrganization",
      },
      'schacHomeOrganizationType' => {
         'langs' => {
            'en' => {
               'dispName' => "Organization Type",
               'dispDescr' => "Type of the home organization",
            },
            'it' => {
               'dispName' => "Tipo di Organizzazione",
               'dispDescr' => "Tipo di Organizzazione",
            },
         },
         'id'                => "schacHomeOrganizationType",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "schacHomeOrganizationType",
         'saml1string'       => "urn:mace:terena.org:schac:attribute-def:schacHomeOrganizationType",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.25178.1.2.10",
         'friendlyName'      => "schacHomeOrganizationType",
      },
      'eduPersonOrgDN' => {
         'langs' => {
            'en' => {
               'dispName' => "Organization path",
               'dispDescr' => "Organization path: The distinguished name (DN) of the directory entry representing the organization with which the person is associated",
            },
            'it' => {
               'dispName' => "DN dell'organizzazione",
               'dispDescr' => "DN dell'organizzazione: Il DN dell'organizzazione a cui &egrave; associato questo utente",
            },
         },
         'id'                => "eduPersonOrgDN",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "eduPersonOrgDN",
         'saml1string'       => "urn:mace:dir:attribute-def:eduPersonOrgDN",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.5923.1.1.1.3",
         'friendlyName'      => "eduPersonOrgDN",
      },
      'eduPersonOrgUnitDN' => {
         'langs' => {
            'en' => {
               'dispName' => "Organizational unit path",
               'dispDescr' => "Organization unit path: The distinguished name (DN) of the directory entries representing the person's Organizational Unit(s)",
            },
            'it' => {
               'dispName' => "DN dell'unit&agrave;",
               'dispDescr' => "DN dell'unit&agrave;: Il DN dell'unit&agrave; organizzativa di questo utente nella sua organizzazione",
            },
         },
         'id'                => "eduPersonOrgUnitDN",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "eduPersonOrgUnitDN",
         'saml1string'       => "urn:mace:dir:attribute-def:eduPersonOrgUnitDN",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.5923.1.1.1.4",
         'friendlyName'      => "eduPersonOrgUnitDN",
      },
      'eduPersonScopedAffiliation' => {
         'langs' => {
            'en' => {
               'dispName' => "Scoped Affiliation",
               'dispDescr' => "Affiliation Scoped: Type of affiliation with Home Organization with scope",
            },
            'it' => {
               'dispName' => "Affiliazione con ambito",
               'dispDescr' => "Affiliazione con ambito: ruolo ricoperto con dominio dell'Organizzazione",
            },
         },
         'id'                => "eduPersonScopedAffiliation",
         'type'              => "ad:Scoped",
         'scope'             => $shib2idp::idp::finalize::scope,
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "eduPersonAffiliation",
         'saml1ScopedString' => "urn:mace:dir:attribute-def:eduPersonScopedAffiliation",
         'scopeTypeSaml1'    => "inline",
         'saml2ScopedString' => "urn:oid:1.3.6.1.4.1.5923.1.1.1.9",
         'scopeTypeSaml2'    => "inline",
         'friendlyName'      => "eduPersonScopedAffiliation",
      },
      'eduPersonPrincipalName' => {
         'langs' => {
            'en' => {
               'dispName' => "eduPersonPrincipalName",
               'dispDescr' => "Unique and persistent Identifier of a person",
            },
            'it' => {
               'dispName' => "eduPersonPrincipalName",
               'dispDescr' => "Identificativo unico persistente di questo utente.",
            },
         },
         'id'                => "eduPersonPrincipalName",
         'type'              => "ad:Scoped",
         'scope'             => $shib2idp::idp::finalize::scope,
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "uid",
         'saml1ScopedString' => "urn:mace:dir:attribute-def:eduPersonPrincipalName",
         'scopeTypeSaml1'    => "inline",
         'saml2ScopedString' => "urn:oid:1.3.6.1.4.1.5923.1.1.1.6",
         'scopeTypeSaml2'    => "inline",
         'friendlyName'      => "eduPersonPrincipalName",
      },
      'eduPersonEntitlement' => {
         'langs' => {
            'en' => {
               'dispName' => "Entitlement",
               'dispDescr' => "Entitlement: URI (either URL or URN) that indicates a set of rights to specific resources based on an agreement across the releavant community",
            },
            'it' => {
               'dispName' => "Entitlement",
               'dispDescr' => "Entitlement: URI (sia URL o URN) che rappresenta diritti specifici d'accesso validi in tutta la community",
            },
         },
         'id'                => "eduPersonEntitlement",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "eduPersonEntitlement",
         'saml1string'       => "urn:mace:dir:attribute-def:eduPersonEntitlement",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.5923.1.1.1.7",
         'friendlyName'      => "eduPersonEntitlement",
      },
      'pwdChangedTime' => {
         'langs' => {
            'en' => {
               'dispName' => "Password's last change time",
               'dispDescr' => "This attribute denotes the last time that the entry's password was changed. This value is used by the password expiration policy to determine whether the password is too old to be allowed to be used for user authentication.",
            },
            'it' => {
               'dispName' => "Tempo ultima modifica password",
               'dispDescr' => "Questo attributo indica l'ultimo momento in cui la password &egrave; stata modificata. Questo valore viene usato per stabilire se la password &egrave; scaduta o meno per la risorsa a cui si vuole accedere",
            },
         },
         'id'                => "pwdChangedTime",
         'type'              => "ad:Simple",
         'dependency'        => "ppLDAP",
         'sourceAttributeID' => "pwdChangedTime",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.42.2.27.8.1.16",
         'friendlyName'      => "pwdChangedTime",
      },
      'uid' => {
         'langs' => {
            'en' => {
               'dispName' => "UserID",
               'dispDescr' => "User Identifier",
            },
            'it' => {
               'dispName' => "UserID",
               'dispDescr' => "Identificativo di questo utente.",
            },
         },
         'id'                => "uid",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "uid",
         'saml1string'       => "urn:mace:dir:attribute-def:uid",
         'saml2string'       => "urn:oid:0.9.2342.19200300.100.1.1",
         'friendlyName'      => "uid",
      },
      'eduPersonAffiliation' => {
         'langs' => {
            'en' => {
               'dispName' => "Affiliation",
               'dispDescr' => "Affiliation: Type of affiliation with Home Organization",
            },
            'it' => {
               'dispName' => "Affiliazione",
               'dispDescr' => "Affiliazione: Tipo di relazione mantenuta con la propria organizzazione.",
            },
         },
         'id'                => "eduPersonAffiliation",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "eduPersonAffiliation",
         'saml1string'       => "urn:mace:dir:attribute-def:eduPersonAffiliation",
         'saml2string'       => "urn:oid:1.3.6.1.4.1.5923.1.1.1.1",
         'friendlyName'      => "eduPersonAffiliation",
      },
      'mailREFEDs' => {
         'langs' => {
         },
         'id'                => "mailREFEDs",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "mail",
         'saml2string'       => "urn:mace:dir:attribute-def:mail",
         'friendlyName'      => "mailREFEDs",
      },
      'eduPersonEntitlementREFEDs' => {
         'langs' => {
         },
         'id'                => "eduPersonEntitlementREFEDs",
         'type'              => "ad:Simple",
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "eduPersonEntitlement",
         'saml2string'       => "urn:mace:dir:attribute-def:eduPersonEntitlement",
         'friendlyName'      => "eduPersonEntitlementREFEDs",
      },
      'eduPersonPrincipalNameREFEDs' => {
         'langs' => {
         },
         'id'                => "eduPersonPrincipalNameREFEDs",
         'type'              => "ad:Scoped",
         'scope'             => $shib2idp::idp::finalize::scope,
         'dependency'        => "myLDAP",
         'sourceAttributeID' => "uid",
         'saml2ScopedString' => "urn:mace:dir:attribute-def:eduPersonPrincipalName",
         'scopeTypeSaml2'    => "inline",
         'friendlyName'      => "eduPersonPrincipalNameREFEDs",
      },
   }
}
