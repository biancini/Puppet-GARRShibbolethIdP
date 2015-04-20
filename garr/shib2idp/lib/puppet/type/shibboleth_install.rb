# This Puppet Resource Type runs the "install.sh" and install the Shibboleth IdP on the underlying system.
#
# Example:
# 
#  shibboleth_install { 'execute_install':
#    idpfqdn          => $idpfqdn,
#    keystorepassword => $keystorepassword,
#    javahome         => $shib2idp::java::params::java_home,
#    tomcathome       => $tomcat::tomcat_home,
#    scope            => $shib2idp::idp::finalize::scope,
#  }

module Puppet

	newtype(:shibboleth_install) do
		@doc = "Install Shibboleth IdP sources downloaded from Internet2 site"

		#autorequire(:file) do
		#	["/tmp", "/dev"]
		#end

		newparam(:name, :namevar => true) do
			desc "The name of the action"
		end

		newparam(:sourcedir) do
			desc "Path where the Shibboleth IdP sources are extracted."
			defaultto "/usr/local/src/shibboleth-identity-provider"
		end

		newparam(:idpfqdn) do
			desc "The Shibboleth IdP's FQDN"
			defaultto Facter.value('fqdn')
		end
    
		newparam(:keystorepassword) do
			desc "The keystore password to be set up"
		end
    
		newparam(:installdir) do
			desc "The Shibboleth IdP installation directory"
			defaultto "/opt/shibboleth-idp"
		end
    
		newparam(:javahome) do
			desc "The Java home"
		end
    
		newparam(:tomcathome) do
			desc "The Tomcat installation directory"
		end
		
		newparam(:curtomcat) do
			desc "The current Tomcat version"
		end
		
		newparam(:scope) do
			desc "The scope for the IdP to be installed"
		end
    
		validate do
			fail("keystorepassword cwd is required") if self[:keystorepassword].nil?
			fail("javahome cwd is required") if self[:javahome].nil?
			fail("tomcathome cwd is required") if self[:tomcathome].nil?
		end

####	ensure property is not necessary, because it is not used.
#			newproperty(:ensure) do
#			desc "Whether the resource is in sync or not."
#
#			defaultto :insync
#
#			def retrieve
#				# Returns always notrun to permit re-installations if something was changed or updated in the source folder.
#				:insync
#			end
#
#			newvalue :outofsync
#			newvalue :insync do
#				# Do nothing only execute install when refreshed
#			end
####	end
      
		def refresh
			debug("Shibboleth_install[name] = " + @parameters[:name].value + ".")
			debug("Shibboleth_install[sourcedir] = " + @parameters[:sourcedir].value + ".")
			debug("Shibboleth_install[idpfqdn] = " + @parameters[:idpfqdn].value + ".")
			debug("Shibboleth_install[keystorepassword] = " + @parameters[:keystorepassword].value + ".")
			debug("Shibboleth_install[installdir] = " + @parameters[:installdir].value + ".")
			debug("Shibboleth_install[javahome] = " + @parameters[:javahome].value + ".")
			debug("Shibboleth_install[tomcathome] = " + @parameters[:tomcathome].value + ".")
			debug("Shibboleth_install[curtomcat] = " + @parameters[:curtomcat].value + ".")
			debug("Shibboleth_install[scope] = " + @parameters[:scope].value + ".")
      
			filename = @parameters[:sourcedir].value + "/autoinstall.properties"  # Creates a new property file to be used for input parameters of Shibboleth IdP installation.
			File.open(filename, "w") do |saved_file|  # Open it and complete it line by line
				saved_file.write("idp.src.dir = " + @parameters[:sourcedir].value + "\n")
				saved_file.write("idp.target.dir = " + @parameters[:installdir].value + "\n")
				saved_file.write("idp.host.name = " + @parameters[:idpfqdn].value + "\n")
				saved_file.write("idp.sealer.password = " + @parameters[:keystorepassword].value + "\n")
				saved_file.write("idp.keystore.password = " + @parameters[:keystorepassword].value + "\n")
				saved_file.write("entityid = https://" + @parameters[:idpfqdn].value + "/idp/shibboleth" + "\n")
				saved_file.write("scope = " + @parameters[:scope].value + "\n")
				saved_file.write("idp.noprompt = true\n")
			end
			
			filename = "/tmp/autoinstall.sh"  # Creates a new bash script who adds JAVA_HOME environment variable to the underlying system and calls the "install.sh" to install the Shibboleth IdP.
			File.open(filename, "w") do |saved_file|  # Open it and complete it line by line
				saved_file.write("#!/bin/bash\n")
				saved_file.write(". /etc/environment\n")
				saved_file.write("export JAVA_HOME\n")
				saved_file.write("\n")
				saved_file.write("cd " + @parameters[:sourcedir].value + "\n")
				saved_file.write("/bin/bash bin/install.sh -Didp.property.file=autoinstall.properties\n")
			end
      
			debug("Executing install script.")
			system("/bin/bash " + filename) or raise Puppet::Error, "Error while installing Shibboleth IdP." # If the system() return 'false' reise up the message "Error while..."

			debug("Copying file for Java Security into java home")
			system("/bin/chown " + @parameters[:curtomcat].value + ":" + @parameters[:curtomcat].value + " " + @parameters[:installdir].value + "/logs/ " + @parameters[:installdir].value + "/metadata/ " + @parameters[:installdir].value + "/credentials/") or raise Puppet::Error, "Error while setting credentials."

			debug("Deleting file " + filename + ".")
			File.delete(filename)
        
		end
	end
end