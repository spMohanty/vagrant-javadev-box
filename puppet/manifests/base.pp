#
# base.pp
# Build Sigmah Vagrant box configuration from modules
# 
# sigmah-vagrant-box
# https://github.com/spMohanty/sigmah-vagrant-box
#

include sigmah


# Install openJDK 1.6
# Note : Installing 1.6 instead of 1.7 or the latest because
# Sigmah is developed under JDK 1.6 and issues like
# the one discussed here : https://groups.google.com/forum/#!searchin/sigmah-dev/lucia/sigmah-dev/vqTWs6_TU-U/KFoYu6_I_DAJ
# come up in case of JDK 1.7
package {"openjdk-6-jdk":
 ensure => installed,
 name => $operatingsystem ? {
   Ubuntu => "openjdk-6-jdk",
   CentOS => "java-1.6.0-openjdk",
 }
}

# Postgresql general config
class { 'postgresql':
  version => '9.2',
  manage_package_repo => true,
  charset => 'UTF8',
  locale  => 'en_US.UTF-8'
}

# Postgresql server config
class { 'postgresql::server':
  config_hash => {
    'ip_mask_deny_postgres_user' => '0.0.0.0/32',
    'ip_mask_allow_all_users'    => '0.0.0.0/0',
    'listen_addresses'           => '*',
    'manage_redhat_firewall'     => true,
  },
} ->

postgresql::db { 'sigmah_database':
  user     => 'sigmah',
  password =>  'sigmah'
}

# Postgresql database config
# no op

# Install Maven to the vagrant users home dir and shell
maven::setup { "maven":
  ensure        => 'present',
  source        => 'apache-maven-3.1.1-bin.tar.gz',
  deploymentdir => '/home/vagrant/apache-maven',
  user          => 'vagrant',
  pathfile      => '/home/vagrant/.bashrc'
} ->

# Sets the Maven Proxy (as the vagrant proxy plugin doesnt yet support proxy)
class {'sigmah::maven_proxy_setup' : } -> 
# Installs the missing gwt maps and gxt plugins manually
class {'sigmah::maven_install_missing_plugins' : }





