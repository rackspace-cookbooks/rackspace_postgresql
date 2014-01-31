require 'spec_helper'

describe 'rackspace_postgresql::server' do
  let(:centos6_run) do
    ChefSpec::Runner.new(platform: 'centos') do |node|
    end.converge(described_recipe)
  end
  let(:ubuntu_1204_run) do
    ChefSpec::Runner.new(platform: 'ubuntu') do |node|
    end.converge(described_recipe)
  end

  before do
    stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  it 'includes server_rhel on centos6' do
    expect(centos6_run).to include_recipe('rackspace_postgresql::server_redhat')
  end

  it 'includes server_debian on ubuntu1204' do
    expect(ubuntu_1204_run).to include_recipe('rackspace_postgresql::server_debian')
  end
end

describe 'rackspace_mysql::_server_rhel.rb' do
  let(:centos6_run) { ChefSpec::Runner.new(platform: 'centos').converge(described_recipe) }
  let(:ubuntu_1204_run) { ChefSpec::Runner.new(platform: 'ubuntu').converge(described_recipe) }
end
