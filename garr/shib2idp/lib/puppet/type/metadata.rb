# This Puppet Resource Type adds metadata files to IdP instalaltion.
#
# Example:
#  
#  metadata { 'ldapadd-test-user':
#    files => {'id1': 'filename1.xml'}
#  }

module Puppet

	newtype(:metadata) do
		@doc = "Adds metadata di IdP installation"
		
		newparam(:name, :namevar => true) do
			desc "The name of the resource"
		end

		newparam(:metadata_files) do
			desc "The file names for metadata files"
		end
		
		newparam(:installdir) do
			desc "The Shibboleth IdP installation directory"
			defaultto "/opt/shibboleth-idp"
		end
    
		validate do
			fail("metadata_files parameter is required to be undef or a validy array") unless self[:metadata_files].nil? or self[:metadata_files].kind_of?(Hash)
		end

		newproperty(:ensure) do
			desc "Whether the resource is in sync or not."

			defaultto :insync

			def retrieve
				synched = true
				
				resource[:metadata_files].each { |id, filename|
				    debug("Looking for file " + resource[:installdir] + "/metadata/" + id + "-metadata.xml.")
					if not File.exist?(resource[:installdir] + "/metadata/" + id + "-metadata.xml")
						synched = false
					end
				}
				
				return (synched) ? :insync : :outofsync
			end # retrieve

			newvalue :outofsync
			newvalue :insync do
				debug("Metadata[installdir] = " + resource[:installdir] + ".")
				debug("Metadata[metadata_files] = " + resource[:metadata_files].inspect + ".")
				
				resource[:metadata_files].each { |id, filename|
                    system("wget --no-check-certificate -O " + resource[:installdir] + "/metadata/" + id + "-metadata.xml " + filename)
                }
			end # insync
		end # ensure
	end # newtype
end # module Puppet
