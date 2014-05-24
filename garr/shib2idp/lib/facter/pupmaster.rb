Facter.add(:pupmaster) do
  setcode do
    pupmaster = ''
    pupconf_file = '/etc/puppet/puppet.conf'

    if File.exists?(pupconf_file)
      File.open(pupconf_file, 'r').each_line do |line|
        if line =~ /^server=/
          pupmaster = line
          pupmaster["server="]= ""
          pupmaster.delete!("\n")
        elsif line =~ /^server = /
          pupmaster = line
          pupmaster["server = "]= ""
          pupmaster.delete!("\n")
        end
      end
    end

    pupmaster
  end
end

