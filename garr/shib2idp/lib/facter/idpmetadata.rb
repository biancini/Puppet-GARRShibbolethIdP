Facter.add(:idpmetadata) do
  setcode do
    metadata_file = '/opt/shibboleth-idp/metadata/idp-metadata.xml'
    File.read(metadata_file) if File.exists?(metadata_file)
  end
end
