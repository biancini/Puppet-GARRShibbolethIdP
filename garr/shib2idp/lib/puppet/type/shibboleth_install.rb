# This Puppet Resource Type runs the "install.sh" and install the Shibboleth IdP on the underlying system.
#
# Example:
# 
#  shibboleth_install { 'execute_install':
#    idpfqdn => $idpfqdn,
#    keystorepassword => $keystorepassword,
#    javahome => $shib2idp::java::params::java_home,
#    tomcathome => $tomcat::tomcat_home,
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
			defaultto "/usr/local/src/shibboleth-identityprovider"
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
      
			filename = "/tmp/autoinstall.sh"  # Creates a new bash script who adds JAVA_HOME environment variable to the underlying system and calls the "install.sh" to install the Shibboleth IdP.
        
			File.open(filename, "w") do |saved_file|  # Open it and complete it line by line
				saved_file.write("#!/bin/bash\n")
				saved_file.write(". /etc/environment\n")
				saved_file.write("export JAVA_HOME\n")
				saved_file.write("\n")
				saved_file.write("cd " + @parameters[:sourcedir].value + "\n")
				saved_file.write("/bin/sh install.sh\n")
			end
      
			debug("Executing install script.")
			system("/bin/bash " + filename) or raise Puppet::Error, "Error while installing Shibboleth IdP." # If the system() return 'false' reise up the message "Error while..."

			debug("Copying file for Java Security into java home")
			# If the file ":sourcedir/lib/shibboleth-jce-1.1.0.jar" exists, copy the Java Security files into Java Home. Pay Attention to the white space into the strings of the system(...)!!!
			if (File.exists?(@parameters[:sourcedir].value + "/lib/shibboleth-jce-1.1.0.jar"))
				system("cp -fv " + @parameters[:sourcedir].value + "/lib/shibboleth-jce-1.1.0.jar " + @parameters[:javahome].value + "/jre/lib/ext/") or raise Puppet::Error, "Error while copying files."
			end
			system("cp -fv /usr/share/" + @parameters[:curtomcat].value + "/lib/servlet-api.jar " + @parameters[:installdir].value + "/lib/") or raise Puppet::Error, "Error while copying files."
			system("/bin/cp -r " + @parameters[:sourcedir].value + "/endorsed/ " + @parameters[:tomcathome].value) or raise Puppet::Error, "Error while copying files."
			system("/bin/chown " + @parameters[:curtomcat].value + ":" + @parameters[:curtomcat].value + " " + @parameters[:installdir].value + "/logs/ " + @parameters[:installdir].value + "/metadata/ " + @parameters[:installdir].value + "/credentials/") or raise Puppet::Error, "Error while setting credentials."

			debug("Deleting file " + filename + ".")
			File.delete(filename)
        
		end
	end
end