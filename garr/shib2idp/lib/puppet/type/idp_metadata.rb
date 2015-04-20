# This Puppet Resource Type modify the file 'idp-metadata.xml'
#
# Example:
#
#   idp_metadata { '/opt/shibboleth-idp/metadata/idp-metadata.xml':
#      filecontent => template(aib2idp/idp-metadata.xml.erb'),
#      metadata => {
#        'en' => {
#          'orgDisplayName' => 'Test IdP for IdP in the cloud project',
#          'communityDesc' => 'GARR Research&amp;Development',
#          'orgUrl' => 'http://www.garr.it/',
#          'privacyPage' => 'http://www.garr.it/',
#          'nameOrg' => 'Consortium GARR',
#          'idpInfoUrl' => 'https://puppetclient.example.com/idp/info.html',
#          'url_LogoOrg_32x32' => 'https://puppetclient.example.com/idp/images/institutionLogo-32x32_en.png',
#          'url_LogoOrg_160x120' => 'https://puppetclient.example.com/idp/images/institutionLogo-160x120_en.png',
#        },
#        'it' => {
#          'orgDisplayName' => 'Test IdP for IdP in the cloud project',
#          'communityDesc' => 'GARR Research&amp;Development',
#          'orgUrl' => 'http://www.garr.it/',
#          'privacyPage' => 'http://www.garr.it/',
#          'nameOrg' => 'Consortium GARR',
#          'idpInfoUrl' => 'https://puppetclient.example.com/idp/info.html',
#          'url_LogoOrg_32x32' => 'https://puppetclient.example.com/idp/images/institutionLogo-32x32_it.png',
#          'url_LogoOrg_160x120' => 'https://puppetclient.example.com/idp/images/institutionLogo-160x120_it.png',
#        },
#        'technicalIDPadminEmail' => 'support@pupperclient.example.com',
#      },
#      certfilename => '/opt/shibboleth-idp/credentials/idp.crt',
#   }

module Puppet

    newtype(:idp_metadata) do
        @doc = "Generate the IdP metadata"

        newparam(:name, :namevar => true) do
            desc "The name of the metadata file to be created"
        end
    
        newparam(:metadata) do
            desc "The metadata information to be put in the metadata file"
            
            validate do |metadatavalue|
                # Rules to be used to validate metadata hash passed as a parameter
                rules = {
                    'en' => {
                        'orgDisplayName' => 'not null',
                        'communityDesc' => 'not null',
                        'idpInfoUrl' => 'valid url',
                        'privacyPage' => 'valid url',
                        'url_LogoOrg_32x32' => 'valid url',
                        'url_LogoOrg_160x120' => 'valid url',
                        'orgUrl' => 'valid url',
                    },
                    'it' => {
                        'orgDisplayName' => 'not null',
                        'communityDesc' => 'not null',
                        'idpInfoUrl' => 'valid url',
                        'privacyPage' => 'valid url',
                        'url_LogoOrg_32x32' => 'valid url',
                        'url_LogoOrg_160x120' => 'valid url',
                        'orgUrl' => 'valid url',
                    },
                    'technicalIDPadminEmail' => 'valid email',
                }
                # Check if the ':metadata' is a valid hash     
                if !metadatavalue.is_a?(Hash)
                  fail("metadata parameter must be a valid hash.")
                end
                # For each value into rules hash
                rules.each do |key, value|
                    # Check if 'value' is a Hash and fails if not exists the key 'key'
                    if value.is_a?(Hash)
                        fail("metadata does not contain elements for language #{key}.") unless metadatavalue.has_key?(key)
                        # Here we know that 'value' is a valid hash and his root is 'metadata[key]'.
                        # For the example defined previously the 'key' values are 'it', 'en' or 'technicalIDPadminEmail'
                        curmetadata = metadatavalue[key]
                        # Example values of 'attribute' and 'check':
                        # attribute 'nameOrg' has the check 'Consortium GARR' 
                        value.each do |attribute, check|
                            case check
                                when 'not null'
                                    fail("metadata does not contain element #{attribute} for language #{key}.") if (!curmetadata.has_key?(attribute) || curmetadata[attribute].empty?)
                                when 'valid url'
                                    fail("metadata does not contain element #{attribute} with a valid url for language #{key}.") if (!curmetadata.has_key?(attribute) || curmetadata[attribute].match(URI::regexp).nil?)
                                when 'valid email'
                                    fail("metadata does not contain element #{attribute} with a valid email for language #{key}.") if (!curmetadata.has_key?(attribute) || curmetadata[attribute].match(/([\w_\-]+\.?)+@([\w_\-]+\.)+[a-zA-Z]{2,6}/).nil?)
                            end 
                        end
                    else
                        case value
                            when 'not null'
                                fail("metadata does not contain element #{key}.") if (!metadatavalue.has_key?(key) || metadatavalue[key].empty?)
                            when 'valid url'
                                fail("metadata does not contain element #{key}.") if (!metadatavalue.has_key?(key) || curmetadata[attribute].match(URI::regexp).nil?)
                            when 'valid email'
                                fail("metadata does not contain element #{key}.") if (!metadatavalue.has_key?(key) || metadatavalue[key].match(/([\w_\-]+\.?)+@([\w_\-]+\.)+[a-zA-Z]{2,6}/).nil?)
                        end
                    end
                end
            end
        end

        newparam(:filecontent) do
            desc "The content of the metadata file to be created"
        end

        newparam(:certfilename_sign) do
            desc "The path of the certificate file for the installed IdP"
            defaultto "/opt/shibboleth-idp/credentials/idp-signing.crt"
        end
        
        newparam(:certfilename_encrypt) do
            desc "The path of the certificate file for the installed IdP"
            defaultto "/opt/shibboleth-idp/credentials/idp-encryption.crt"
        end
        
        newparam(:certfilename_back) do
            desc "The path of the certificate file for the installed IdP"
            defaultto "/opt/shibboleth-idp/credentials/idp-backchannel.crt"
        end
    
        validate do
            fail("filecontent parameter is required") if self[:filecontent].nil?
            fail("certfilename_sign parameter is required") if self[:certfilename_sign].nil?
            fail("certfilename_encrypt parameter is required") if self[:certfilename_encrypt].nil?
            fail("certfilename_back parameter is required") if self[:certfilename_back].nil?
            fail("metadata is required") if self[:metadata].nil? 
        end

        newproperty(:ensure) do
            desc "Whether the resource is in sync or not."

            defaultto :insync

            def retrieve
                require "cgi"
                require "rexml/document"

                downloadTemplate = false
                changeCert = false
                # If 'idp-metadata.xml' exists, verify and change his certificate.
                begin
                    # Open the XML file into 'resource[:name]' with read permission
                    # and create a new xmldoc to modify it
                    xmlfile = File.open(resource[:name], "r")
                    xmldoc = REXML::Document.new xmlfile

                    # Retrieve the source certificate and remove the BEGIN and END CERTIFICATE
                    sourceCertSign = File.readlines(resource[:certfilename_sign])
                    sourceCertSign.delete_if {|x| x.include?('-----') }
                    
                    sourceCertEncrypt = File.readlines(resource[:certfilename_encrypt])
                    sourceCertEncrypt.delete_if {|x| x.include?('-----') }
                    
                    sourceCertBackchannel = File.readlines(resource[:certfilename_back])
                    sourceCertBackchannel.delete_if {|x| x.include?('-----') }
                    
                    changeCertSign = true
                    changeCertEncrypt = true
                    changeCertBackchannel = true

                    # Verify if the certificate must be synchronized or not. 
                    # 'sourceCert.join' convert the array sourceCert into a string
                    REXML::XPath.each(xmldoc, "//ds:X509Certificate") do |e|
                        if e.text.to_s == sourceCertSign.join then
                            changeCertSign = false
                        end
                        
                        if e.text.to_s == sourceCertEncrypt.join then
                            changeCertEncrypt = false
                        end
                        
                        if e.text.to_s == sourceCertBackchannel.join then
                            changeCertBackchannel = false
                        end
                    end
                    
                    changeCert = changeCertSign or changeCertEncrypt or changeCertBackchannel

                    # Verify if the MDUI Information must be synchronized or not
                    rules = {
                      "//mdui:DisplayName" => [resource[:metadata]['en']['orgDisplayName'], resource[:metadata]['it']['orgDisplayName']],
                      "//OrganizationName" => [resource[:metadata]['en']['nameOrg'], resource[:metadata]['it']['nameOrg']],
                      "//mdui:Description" => [resource[:metadata]['en']['communityDesc'], resource[:metadata]['it']['communityDesc']],
                      "//mdui:InformationURL" => [resource[:metadata]['en']['idpInfoUrl'], resource[:metadata]['it']['idpInfoUrl']],
                      "//mdui:PrivacyStatementURL" => [resource[:metadata]['en']['privacyPage'], resource[:metadata]['it']['privacyPage']],
                      "//mdui:Logo" => [resource[:metadata]['en']['url_LogoOrg_32x32'], resource[:metadata]['it']['url_LogoOrg_32x32'], resource[:metadata]['en']['url_LogoOrg_160x120'], resource[:metadata]['it']['url_LogoOrg_160x120']],
                      "//OrganizationDisplayName" => [resource[:metadata]['en']['orgDisplayName'], resource[:metadata]['it']['orgDisplayName']],
                      "//OrganizationURL" => [resource[:metadata]['en']['orgUrl'], resource[:metadata]['it']['orgUrl']],
                      "//EmailAddress" => [resource[:metadata]['technicalIDPadminEmail']],
                    }

                    rules.each do |key, value|
                        REXML::XPath.each(xmldoc, key) do |e|
                            expectedval = CGI.escapeHTML(e.text.to_s)
                            downloadTemplate = (downloadTemplate || !value.include?(expectedval))
                            debug("Error while checking #{key}. Value #{value} found and not #{expectedval}.") if !value.include?(expectedval)
                        end
                    end
                # Otherwise, if 'idp-metadata.xml' not exists.
                rescue Exception
                    downloadTemplate = true
                end # begin
                 
                (downloadTemplate or changeCert) ? :outofsync : :insync
            end # retrieve

            newvalue :outofsync
            
            newvalue :insync do
                debug("Idp_metadata[name] = " + resource[:name] + ".")
                debug("Idp_metadata[metadata] = " + (resource[:metadata].nil? ? "NULL" : resource[:metadata].to_s) + ".")
                debug("Idp_metadata[filecontent] = " + resource[:filecontent] + ".")
                debug("Idp_metadata[certfilename_sign] = " + resource[:certfilename_sign] + ".")
                debug("Idp_metadata[certfilename_encrypt] = " + resource[:certfilename_encrypt] + ".")
                debug("Idp_metadata[certfilename_back] = " + resource[:certfilename_back] + ".")
       
                xmldoc = resource[:filecontent]
                
                # Retrieve the source certificate and remove the BEGIN and END CERTIFICATE        
                sourceCertSign = File.readlines(resource[:certfilename_sign])
                sourceCertSign.delete_if {|x| x.include?('-----') }
                
                sourceCertEncrypt = File.readlines(resource[:certfilename_encrypt])
                sourceCertEncrypt.delete_if {|x| x.include?('-----') }
                
                sourceCertBackchannel = File.readlines(resource[:certfilename_back])
                sourceCertBackchannel.delete_if {|x| x.include?('-----') }
     
                # Insert the new certificate into the right position on idp-metadata.xml file.
                xmldoc = xmldoc.gsub(/\$IDP_CERTIFICATE_SIGN/, sourceCertSign.join)
                xmldoc = xmldoc.gsub(/\$IDP_CERTIFICATE_ENCRYPT/, sourceCertEncrypt.join("\n"))
                xmldoc = xmldoc.gsub(/\$IDP_CERTIFICATE_BACK/, sourceCertBackchannel.join("\n"))
                
                # Here the 'xmldoc' contains the correct XML content. 
          
                # Now creates a new 'idp-metadata.xml' file and saves in it the new content stored into 'xmldoc'
                File.open(resource[:name], "w") {|file| file.puts xmldoc}

            end # :insync
        end # ensure
    end # newtype
end # module
