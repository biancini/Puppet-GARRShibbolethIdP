# This type verify if the user 'user_name' is contained into LDAP
#
# Example of declaration on the puppet manifests:
#
#     verify_user { "test":
#         rootdn      => "cn=admin,dc=example,dc=com",
#         rootpw      => ldappassword,
#         ldif_search => "uid=test,ou=people,dc=example,dc=com",
#         ldif        => template("shib2idp/testuser.ldif.erb"),
#         hostname    => "localhost"
#  }

# Include methods into module Puppet
module Puppet

  newtype(:verify_user) do
    @doc = "Verify the existence of an user on LDAP "

      newparam(:searchuser, :namevar => true) do
        desc "The user DN to find"

        defaultto "uid=test,ou=people"
      end
    
      newparam(:basedn) do
        desc "The Ldap's Base DN"

        defaultto "dc=example,dc=com"
      end

      newparam(:adminuser) do
        desc "The Ldap's Admin User"

        defaultto "cn=admin"
      end

      newparam(:ldappasswd) do
        desc "The Ldap's DB password"

        defaultto "ldappassword"
      end

      newparam(:ldapsrv) do
        desc "The database host name"

        defaultto "localhost"
      end

      newparam(:idphome) do
        desc "The IdP installation home directory"
        
        defaultto "/opt/shibboleth-idp"
      end
      
      newparam(:fqdn) do
        desc "The Full Qualified Domain Name of agent"
        
        defaultto Facter.fqdn
      end
      
      newparam(:ssl) do
        desc "Set it to 'true' if your Ldap connection use SSL"
        
        defaultto false
      end
      
      newparam(:tls) do
        desc "Set it to 'true' if your Ldap connection use TLS"
         
        defaultto false
      end


      validate do
        fail("'basedn' parameter is required") if self[:basedn].nil?
        fail("'adminuser' parameter is required") if self[:adminuser].nil?
        fail("'ldappasswd' parameter is required") if self[:ldappasswd].nil?
        fail("'ldapsrv' parameter is required") if self[:ldapsrv].nil?
        fail("'searchuser' parameter is required") if self[:searchuser].nil?
        fail("'idphome' parameter is required") if self[:idphome].nil?
      end

      def refresh
        require 'ldap'
        require 'rexml/document'

        debug("Verify_user[adminuser]: " + @parameters[:adminuser].value)
        debug("Verify_user[basedn]: " + @parameters[:basedn].value)
        debug("Verify_user[ldappasswd]: " + @parameters[:ldappasswd].value)
        debug("Verify_user[ldapsrv]: " + @parameters[:ldapsrv].value)
        debug("Verify_user[searchuser]: " + @parameters[:searchuser].value)
        debug("Verify_user[idphome]: " + @parameters[:idphome].value)
        debug("Verify_user[fqdn]: " + @parameters[:fqdn].value)

        ldapsrv = @parameters[:ldapsrv].value
        ldapport = 0
        if ldapsrv.include?(':')
          ldapport = ldapsrv.split(':')[1].to_i
          ldapsrv = ldapsrv.split(':')[0]
        end
        
        if (@parameters[:ssl].value == true)
          if ldapport == 0
  	        ldapport = LDAP::LDAPS_PORT
          end
          conn = LDAP::SSLConn.new(ldapsrv, ldapport, start_tls = false) or raise puts("LDAP SSL Connection failed")
        elsif (@parameters[:tls].value == true)
          if ldapport == 0
  	        ldapport = LDAP::LDAPS_PORT
          end
          conn = LDAP::SSLConn.new(ldapsrv, ldapport, start_tls = true) or raise puts("LDAP TLS Connection failed")
        else
          if ldapport == 0
  	        ldapport = LDAP::LDAP_PORT
          end
          conn = LDAP::Conn.new(ldapsrv, ldapport) or raise puts("LDAP Plain Connection failed")
        end
        
        conn.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 ) or raise puts("Connectin failed")
        conn.bind(@parameters[:adminuser].value + "," + @parameters[:basedn].value, @parameters[:ldappasswd].value) or raise puts("Binding failed")

        user_found = false
        wrong_attribute = false
        wrongs = Array.new
          
        begin
          aaclicommand = @parameters[:idphome].value+"/bin/aacli.sh --issuer=https://"+@parameters[:fqdn].value+"/idp/shibboleth --principal=test --configDir="+@parameters[:idphome].value+"/conf"
          aaclioutput = %x[bash -c "source /etc/environment; export JAVA_HOME; #{aaclicommand}"]

          xmlstring = ""
          addtostring = false
          aaclioutput.each { |line|
             addtostring = true if line.include?("<?xml")
             xmlstring = "#{xmlstring}\n#{line}" if addtostring
          }
      
          # Open the XML string and create a new xmldoc to modify it
          xmldoc = REXML::Document.new xmlstring
          # Perform a search, with the base DN 'resource[:ldif_search]', 
          # the scope LDAP::LDAP_SCOPE_BASE (Search only the base node)
          # the search filter '(objectclass=*)' ==> any objectclass
          # the attributes that the search should return ( ['*'] == All Attributes)
          attrs = [
                  'sn',
                  'givenName',
                  'cn',
                  'houseIdentifier',
                  'street',
                  'l',
                  'postalCode',
                  'st',
                  'c',
                  'telephoneNumber',
                  'o',
                  'ou',
                  'co',
                  'mail',
                  'displayName',
                  'schacDateOfBirth',
                  'schacYearOfBirth',
                  'schacPlaceOfBirth',
                  'schacPersonalUniqueID',
                  'schacPersonalPosition',
                  'schacHomeOrganization',
                  'schacHomeOrganizationType',
                  'eduPersonOrgDN',
                  'eduPersonOrgUnitDN',
                  'eduPersonScopedAffiliation',
                  'eduPersonPrincipalName',
                  'eduPersonEntitlement',
                  'eduPersonTargetedID',
                   ] 

          conn.search(@parameters[:searchuser].value + "," + @parameters[:basedn].value, LDAP::LDAP_SCOPE_BASE, '(objectclass=*)', attrs) do |entry|
            entry.attrs.each do |saml_attr|
            if entry.vals("#{saml_attr}").to_s != REXML::XPath.match(xmldoc, "//saml2:Attribute[@FriendlyName='#{saml_attr}']/saml2:AttributeValue/text()" ).to_s
              wrong_attribute = true 
              wrongs.push(xmlstring) if wrongs.empty? 
              wrongs.push(entry.vals("#{saml_attr}").to_s + " != " + REXML::XPath.match(xmldoc, "//saml2:Attribute[@FriendlyName='#{saml_attr}']/saml2:AttributeValue/text()" ).to_s)
            end
          end

          user_found = true
        end #begin
        # If the search fails an LDAP::ResultError exception will raise up
        # The LDAP::ResultError will be saved into 'err' variable
        rescue LDAP::ResultError => err
          fail("Ldap Search for user " + @parameters[:searchuser].value + " is failed with  error: #{err}")
        # In case of an error, the new, bind or unbind methods raise an LDAP::Error exception
        # The LDAP::Error will be saved into 'msg' variable
        rescue LDAP::Error => msg
         # If an LDAP::Error exception rises up, Puppet show that exception message into its exception error 
         raise(Puppet::Error, "Error while executing LDAP search for " + @parameters[:searchuser].value + "," + @parameters[:basedn].value + ": #{msg}")
        end # rescue

       # Finally unbind the LDAP connection
       conn.unbind

       if (user_found == true)
         if (wrong_attribute == false)
           info("OK. User found with the correct attributes.")
         else
           info("WARNING. User found but with wrong attributes.\n" + wrongs.join("\n"))
         end
       else 
           fail("CRITICAL. User not found.")
       end

      end #refresh
    end # newtype
end # module Puppet
