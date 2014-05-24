#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/ldapserver'

describe 'Facter::Util::Fact' do
  before { Facter.clear }
  after { Facter.clear }

  it 'openldap' do
    File.stubs(:exists?).returns(true)
    File.stubs(:open).returns(['openldap'])
    Facter.fact(:ldapserver).value.should == 'openldap'
  end
end
