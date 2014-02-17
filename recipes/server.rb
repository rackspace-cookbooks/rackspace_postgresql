#
# Cookbook Name:: rackspace_postgresql
# Recipe:: server
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)
# Author:: Matthew Thode (<matt.thode@rackspace.com>)
# Copyright 2009-2011, Opscode, Inc.
# Copyright 2014, Rackspace, US Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'digest/md5'

if node['rackspace_postgresql']['password'] == "thiswillbecomearandompassword"
  ::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
else
  secure_password = Digest::MD5.hexdigest("#{node['rackspace_postgresql']['password']}")
end

include_recipe 'rackspace_postgresql::client'

# randomly generate postgres password, unless using solo - see README
if Chef::Config[:solo]
  missing_attrs = %w{
    postgres
  }.select { |attr| node['rackspace_postgresql']['password'][attr].nil? }.map { |attr| "node['rackspace_postgresql']['password']['#{attr}']" }
#  }.select do |attr|
#    node['rackspace_postgresql']['password'][attr].nil?
#  end.map { |attr| "node['rackspace_postgresql']['password']['#{attr}']" }

  unless missing_attrs.empty?
    Chef::Application.fatal!([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        'For more information, see https://github.com/opscode-cookbooks/postgresql#chef-solo-note'
      ].join(' '))
  end
else
  # TODO: The "secure_password" is randomly generated plain text, so it
  # should be converted to a PostgreSQL specific "encrypted password" if
  # it should actually install a password (as opposed to disable password
  # login for user 'postgres'). However, a random password wouldn't be
  # useful if it weren't saved as clear text in Chef Server for later
  # retrieval.
  node.set_unless['rackspace_postgresql']['password']['postgres'] = secure_password
  node.save
end


# Include the right "family" recipe for installing the server
# since they do things slightly differently.
case node['platform_family']
when 'rhel'
  include_recipe 'rackspace_postgresql::server_redhat'
when 'debian'
  include_recipe 'rackspace_postgresql::server_debian'
end

# change_notify = node['rackspace_postgresql']['server']['config_change_notify']

template "#{node['rackspace_postgresql']['dir']}/postgresql.conf" do
  helpers(Format)
  source 'postgresql.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode 0600
  notifies :reload, 'service[postgresql]', :immediately
end

template "#{node['rackspace_postgresql']['dir']}/pg_hba.conf" do
  source 'pg_hba.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode 00600
  notifies :reload, 'service[postgresql]', :immediately
end

# NOTE: Consider two facts before modifying "assign-postgres-password":
# (1) Passing the "ALTER ROLE ..." through the psql command only works
#     if passwordless authorization was configured for local connections.
#     For example, if pg_hba.conf has a "local all postgres ident" rule.
bash 'assign-postgres-password' do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node['rackspace_postgresql']['password']['postgres']}';" | psql
  EOH
  action :run
end
