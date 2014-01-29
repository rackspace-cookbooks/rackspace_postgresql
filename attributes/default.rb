#
# Cookbook Name:: postgresql
# Attributes:: postgresql
#
# Copyright 2008-2009, Opscode, Inc.
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

default['rackspace_postgresql']['enable_pgdg_apt'] = false
# default['rackspace_postgresql']['server']['config_change_notify'] = :restart

case node['platform']
when 'debian'

  case
  when node['platform_version'].to_f < 6.0 # All 5.X
    default['rackspace_postgresql']['version'] = '8.3'
  when node['platform_version'].to_f < 7.0 # All 6.X
    default['rackspace_postgresql']['version'] = '8.4'
  else
    default['rackspace_postgresql']['version'] = '9.1'
  end

  default['rackspace_postgresql']['dir'] = "/etc/postgresql/#{node['rackspace_postgresql']['version']}/main"
  case
  when node['platform_version'].to_f < 6.0 # All 5.X
    default['rackspace_postgresql']['server']['service_name'] = "postgresql-#{node['rackspace_postgresql']['version']}"
  else
    default['rackspace_postgresql']['server']['service_name'] = 'postgresql'
  end

  default['rackspace_postgresql']['client']['packages'] = ["postgresql-client-#{node['rackspace_postgresql']['version']}", 'libpq-dev']
  default['rackspace_postgresql']['server']['packages'] = ["postgresql-#{node['rackspace_postgresql']['version']}"]
  default['rackspace_postgresql']['contrib']['packages'] = ["postgresql-contrib-#{node['rackspace_postgresql']['version']}"]

when 'ubuntu'

  case
  when node['platform_version'].to_f <= 9.04
    default['rackspace_postgresql']['version'] = '8.3'
  when node['platform_version'].to_f <= 11.04
    default['rackspace_postgresql']['version'] = '8.4'
  else
    default['rackspace_postgresql']['version'] = '9.1'
  end

  default['rackspace_postgresql']['dir'] = "/etc/postgresql/#{node['rackspace_postgresql']['version']}/main"
  case
  when (node['platform_version'].to_f <= 10.04) && (!node['rackspace_postgresql']['enable_pgdg_apt'])
    default['rackspace_postgresql']['server']['service_name'] = "postgresql-#{node['rackspace_postgresql']['version']}"
  else
    default['rackspace_postgresql']['server']['service_name'] = 'postgresql'
  end

  default['rackspace_postgresql']['client']['packages'] = ["postgresql-client-#{node['rackspace_postgresql']['version']}", 'libpq-dev']
  default['rackspace_postgresql']['server']['packages'] = ["postgresql-#{node['rackspace_postgresql']['version']}"]
  default['rackspace_postgresql']['contrib']['packages'] = ["postgresql-contrib-#{node['rackspace_postgresql']['version']}"]

when 'redhat', 'centos'

  default['rackspace_postgresql']['version'] = '8.4'
  default['rackspace_postgresql']['dir'] = '/var/lib/pgsql/data'

  if node['platform_version'].to_f >= 6.0 && node['rackspace_postgresql']['version'] == '8.4'
    default['rackspace_postgresql']['client']['packages'] = %w{postgresql-devel}
    default['rackspace_postgresql']['server']['packages'] = %w{postgresql-server}
    default['rackspace_postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  else
    default['rackspace_postgresql']['client']['packages'] = ["postgresql#{node['rackspace_postgresql']['version'].split('.').join}-devel"]
    default['rackspace_postgresql']['server']['packages'] = ["postgresql#{node['rackspace_postgresql']['version'].split('.').join}-server"]
    default['rackspace_postgresql']['contrib']['packages'] = ["postgresql#{node['rackspace_postgresql']['version'].split('.').join}-contrib"]
  end

  if node['platform_version'].to_f >= 6.0 && node['rackspace_postgresql']['version'] != '8.4'
    default['rackspace_postgresql']['dir'] = "/var/lib/pgsql/#{node['rackspace_postgresql']['version']}/data"
    default['rackspace_postgresql']['server']['service_name'] = "postgresql-#{node['rackspace_postgresql']['version']}"
  else
    default['rackspace_postgresql']['dir'] = '/var/lib/pgsql/data'
    default['rackspace_postgresql']['server']['service_name'] = 'postgresql'
  end

  # These defaults have disparity between which postgresql configuration
  # settings are used because they were extracted from the original
  # configuration files that are now removed in favor of dynamic
  # generation.
  #
  # While the configuration ends up being the same as the default
  # in previous versions of the cookbook, the content of the rendered
  # template will change, and this will result in service notification
  # if you upgrade the cookbook on existing systems.
  #
  # The ssl config attribute is generated in the recipe to avoid awkward
  # merge/precedence order during the Chef run.
  case node['platform_family']
  when 'debian'
    default['rackspace_postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['rackspace_postgresql']['version']}/main"
    default['rackspace_postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['rackspace_postgresql']['version']}/main/pg_hba.conf"
    default['rackspace_postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['rackspace_postgresql']['version']}/main/pg_ident.conf"
    default['rackspace_postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['rackspace_postgresql']['version']}-main.pid"
    default['rackspace_postgresql']['config']['listen_addresses'] = 'localhost'
    default['rackspace_postgresql']['config']['port'] = 5432
    default['rackspace_postgresql']['config']['max_connections'] = 100
    default['rackspace_postgresql']['config']['unix_socket_directory'] = '/var/run/postgresql' if node['rackspace_postgresql']['version'].to_f < 9.3
    default['rackspace_postgresql']['config']['unix_socket_directories'] = '/var/run/postgresql' if node['rackspace_postgresql']['version'].to_f >= 9.3
    default['rackspace_postgresql']['config']['shared_buffers'] = '24MB'
    default['rackspace_postgresql']['config']['max_fsm_pages'] = 153_600 if node['rackspace_postgresql']['version'].to_f < 8.4
    default['rackspace_postgresql']['config']['log_line_prefix'] = '%t '
    default['rackspace_postgresql']['config']['datestyle'] = 'iso, mdy'
    default['rackspace_postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
    default['rackspace_postgresql']['config']['ssl'] = true
  when 'rhel'
    default['rackspace_postgresql']['config']['listen_addresses'] = 'localhost'
    default['rackspace_postgresql']['config']['max_connections'] = 100
    default['rackspace_postgresql']['config']['shared_buffers'] = '32MB'
    default['rackspace_postgresql']['config']['logging_collector'] = true
    default['rackspace_postgresql']['config']['log_directory'] = 'pg_log'
    default['rackspace_postgresql']['config']['log_filename'] = 'rackspace_postgresql-%a.log'
    default['rackspace_postgresql']['config']['log_truncate_on_rotation'] = true
    default['rackspace_postgresql']['config']['log_rotation_age'] = '1d'
    default['rackspace_postgresql']['config']['log_rotation_size'] = 0
    default['rackspace_postgresql']['config']['datestyle'] = 'iso, mdy'
    default['rackspace_postgresql']['config']['lc_messages'] = 'en_US.UTF-8'
    default['rackspace_postgresql']['config']['lc_monetary'] = 'en_US.UTF-8'
    default['rackspace_postgresql']['config']['lc_numeric'] = 'en_US.UTF-8'
    default['rackspace_postgresql']['config']['lc_time'] = 'en_US.UTF-8'
    default['rackspace_postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
  end

  default['rackspace_postgresql']['pg_hba'] = [
    { type: 'local', db: 'all', user: 'rackspace_postgres', addr: nil, method: 'ident' },
    { type: 'local', db: 'all', user: 'all', addr: nil, method: 'ident' },
    { type: 'host', db: 'all', user: 'all', addr: '127.0.0.1/32', method: 'md5' },
    { type: 'host', db: 'all', user: 'all', addr: '::1/128', method: 'md5' }
  ]

  default['rackspace_postgresql']['password'] = {}

  case node['platform_family']
  when 'debian'
    default['rackspace_postgresql']['pgdg']['release_apt_codename'] = node['lsb']['codename']
  end

  default['rackspace_postgresql']['enable_pgdg_yum'] = false

  default['rackspace_postgresql']['initdb_locale'] = nil

  # The PostgreSQL RPM Building Project built repository RPMs for easy
  # access to the PGDG yum repositories. Links to RPMs for installation
  # on the supported version/platform combinations are listed at
  # http://yum.postgresql.org/repopackages.php, and the links for
  # PostgreSQL 8.4, 9.0, 9.1, 9.2 and 9.3 are captured below.
  #
  # The correct RPM for installing /etc/yum.repos.d is based on:
  # * the attribute configuring the desired Postgres Software:
  #   node['rackspace_postgresql']['version']        e.g., "9.1"
  # * the chef ohai description of the target Operating System:
  #   node['platform']                     e.g., "centos"
  #   node['platform_version']             e.g., "5.7", truncated as "5"
  #   node['kernel']['machine']            e.g., "i386" or "x86_64"
  default['rackspace_postgresql']['pgdg']['repo_rpm_url'] = {
    '9.3' => {
      'centos' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-i386/pgdg-centos93-9.3-1.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/9.3/redhat/rhel-5-i386/pgdg-centos93-9.3-1.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/pgdg-centos93-9.3-1.noarch.rpm'
        }
      },
      'redhat' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-i386/pgdg-redhat93-9.3-1.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/9.3/redhat/rhel-5-i386/pgdg-redhat93-9.3-1.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/pgdg-redhat93-9.3-1.noarch.rpm'
        }
      }
    },
    '9.2' => {
      'centos' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-centos92-9.2-6.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-centos92-9.2-6.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-centos92-9.2-6.noarch.rpm'
        }
      },
      'redhat' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-redhat92-9.2-7.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-redhat92-9.2-7.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-redhat92-9.2-7.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-redhat92-9.2-7.noarch.rpm'
        }
      }
    },
    '9.1' => {
      'centos' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-centos91-9.1-4.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-centos91-9.1-4.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-centos91-9.1-4.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-centos91-9.1-4.noarch.rpm'
        },
        '4' => {
          'i386' => 'http://yum.postgresql.org/9.1/redhat/rhel-4-i386/pgdg-centos91-9.1-4.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.1/redhat/rhel-4-x86_64/pgdg-centos91-9.1-4.noarch.rpm'
        }
      },
      'redhat' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-redhat91-9.1-5.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-redhat91-9.1-5.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-redhat91-9.1-5.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-redhat91-9.1-5.noarch.rpm'
        },
        '4' => {
          'i386' => 'http://yum.postgresql.org/9.1/redhat/rhel-4-i386/pgdg-redhat-9.1-4.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.1/redhat/rhel-4-x86_64/pgdg-redhat-9.1-4.noarch.rpm'
        }
      }
    },
    '9.0' => {
      'centos' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/9.0/redhat/rhel-6-i386/pgdg-centos90-9.0-5.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-centos90-9.0-5.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/9.0/redhat/rhel-5-i386/pgdg-centos90-9.0-5.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-centos90-9.0-5.noarch.rpm'
        },
        '4' => {
          'i386' => 'http://yum.postgresql.org/9.0/redhat/rhel-4-i386/pgdg-centos90-9.0-5.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.0/redhat/rhel-4-x86_64/pgdg-centos90-9.0-5.noarch.rpm'
        }
      },
      'redhat' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/9.0/redhat/rhel-6-i386/pgdg-redhat90-9.0-5.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-redhat90-9.0-5.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/9.0/redhat/rhel-5-i386/pgdg-redhat90-9.0-5.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-redhat90-9.0-5.noarch.rpm'
        },
        '4' => {
          'i386' => 'http://yum.postgresql.org/9.0/redhat/rhel-4-i386/pgdg-redhat90-9.0-5.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/9.0/redhat/rhel-4-x86_64/pgdg-redhat90-9.0-5.noarch.rpm'
        }
      }
    },
    '8.4' => {
      'centos' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/8.4/redhat/rhel-6-i386/pgdg-centos-8.4-3.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/8.4/redhat/rhel-6-x86_64/pgdg-centos-8.4-3.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/8.4/redhat/rhel-5-i386/pgdg-centos-8.4-3.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/8.4/redhat/rhel-5-x86_64/pgdg-centos-8.4-3.noarch.rpm'
        },
        '4' => {
          'i386' => 'http://yum.postgresql.org/8.4/redhat/rhel-4-i386/pgdg-centos-8.4-3.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/8.4/redhat/rhel-4-x86_64/pgdg-centos-8.4-3.noarch.rpm'
        }
      },
      'redhat' => {
        '6' => {
          'i386' => 'http://yum.postgresql.org/8.4/redhat/rhel-6-i386/pgdg-redhat-8.4-3.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/8.4/redhat/rhel-6-x86_64/pgdg-redhat-8.4-3.noarch.rpm'
        },
        '5' => {
          'i386' => 'http://yum.postgresql.org/8.4/redhat/rhel-5-i386/pgdg-redhat-8.4-3.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/8.4/redhat/rhel-5-x86_64/pgdg-redhat-8.4-3.noarch.rpm'
        },
        '4' => {
          'i386' => 'http://yum.postgresql.org/8.4/redhat/rhel-4-i386/pgdg-redhat-8.4-3.noarch.rpm',
          'x86_64' => 'http://yum.postgresql.org/8.4/redhat/rhel-4-x86_64/pgdg-redhat-8.4-3.noarch.rpm'
        }
      }
    }
  }
end
