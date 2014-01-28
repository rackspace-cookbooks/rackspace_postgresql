name              'rackspace_postgresql'
maintainer        'Rackspace, US Inc.'
maintainer_email  'rackspace-cookbooks@rackspace.com'
license           'Apache 2.0'
description       'Installs and configures postgresql for clients or servers'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '4.0.0'
recipe            'rackspace_postgresql', 'Includes rackspace_postgresql::client'
recipe            'rackspace_postgresql::ruby', 'Installs pg gem for Ruby bindings'
recipe            'rackspace_postgresql::client', 'Installs postgresql client package(s)'
recipe            'rackspace_postgresql::server', 'Installs postgresql server packages, templates'
recipe            'rackspace_postgresql::server_redhat', 'Installs postgresql server packages, redhat family style'
recipe            'rackspace_postgresql::server_debian', 'Installs postgresql server packages, debian family style'

%w{ubuntu debian}.each do |os|
  supports os
end

%w{redhat centos}.each do |el|
  supports el, '>= 6.0'
end

depends 'rackspace_build_essential'
depends 'rackspace_apt'
depends 'openssl'
