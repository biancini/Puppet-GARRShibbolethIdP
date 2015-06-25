#!/usr/bin/ruby

require 'puppet'

module Puppet::Parser::Functions
  newfunction(:file_exists, :type => :rvalue) do |args|
    if Puppet::FileServing::Content.indirection.find(args[0], :environment => resource.catalog.environment_instance, :links => resource[:links]).to_s == ''
      return 0
    else
      return 1
    end
  end
end