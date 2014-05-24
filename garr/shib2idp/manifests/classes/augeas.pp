# == Class: shib2idp::augeas
#
# This class ensure the presence of Augeas on Puppet agent machine.
# Augeas is used to manipulate configuration files and to perform all the relevant configuration
# operations requested to have the Shibboleth IdP properly configured and running.
#
# Information about Augeas can be found at this link:
# {http://augeas.net/}[http://augeas.net/].
#
# Parameters:
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2idp::augeas (
  $augeas_version = undef,
  $augeas_ruby_version = undef,
) {

  $lens_dir        = '/usr/share/augeas/lenses'

  $version         = $augeas_version ? {
    ''      => 'present',
    undef   => 'present',
    default => $augeas_version
  }

  $rubylib_version = $augeas_ruby_version ? {
    ''      => 'present',
    undef   => 'present',
    default => $augeas_ruby_version,
  }

  if($lsbdistid == 'Ubuntu'){
    package { ['augeas-lenses','libaugeas0','augeas-tools','libaugeas-ruby1.8']:
      ensure => 'present',
    }
  }
  elsif($lsbdistid == 'Debian' and $lsbdistcodename == 'squeeze'){
    apt_repository { 'backports_repository':
      repository_type    => ['deb'],
      repository_url     => 'http://backports.debian.org/debian-backports',
      repository_targets => ['squeeze-backports', 'main'],
    } 

    file { '/etc/apt/preferences.d/augeas':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => join(["Package: augeas-lenses",
                       "Pin: release a=squeeze-backports",
                       "Pin-Priority: 999",
                       "",
                       "Package: libaugeas0",
                       "Pin: release a=squeeze-backports",
                       "Pin-Priority: 999",
                       "",
                      "Package: augeas-tools",
                       "Pin: release a=squeeze-backports",
                       "Pin-Priority: 999",
                       "",
                       "Package: libaugeas-ruby1.8",
                       "Pin: release a=squeeze-backports",
                       "Pin-Priority: 999"], "\n"),
    }

    package {
      ['augeas-lenses','libaugeas0','augeas-tools']:
        ensure  => $version,
        require => Apt_repository['backports_repository'];

      'libaugeas-ruby1.8':
        ensure  => $rubylib_version,
        require => Apt_repository['backports_repository'];
      }
  }
  # All other supported systems: Debian Wheezy
  else{
    package { ['augeas-lenses','libaugeas0','augeas-tools','libaugeas-ruby1.9.1']:
      ensure => 'present',
    }
  }

  # ensure no file not managed by puppet ends up in there.
  file {
    "${lens_dir}":
      ensure       => directory,
      purge        => true,
      force        => true,
      recurse      => true,
      recurselimit => 1,
      mode         => '0644',
      owner        => 'root',
      group        => 'root',
      require      => Package['augeas-lenses'];

    "${lens_dir}/dist":
      ensure  => directory,
      purge   => false,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package['augeas-lenses'];

    "${lens_dir}/tests":
      ensure  => directory,
      purge   => true,
      force   => true,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package['augeas-lenses'];
  }

}