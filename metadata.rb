name              'rackspace_postgresql'
maintainer        'Rackspace, US Inc.'
maintainer_email  'rackspace-cookbooks@rackspace.com'
license           'Apache 2.0'
description       'Installs and configures postgresql for clients or servers'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '4.0.0'

%w{ubuntu debian}.each do |os|
  supports os
end

%w{redhat centos}.each do |el|
  supports el, '>= 6.0'
end

depends 'rackspace_build_essential'
depends 'rackspace_apt'
depends 'openssl'
