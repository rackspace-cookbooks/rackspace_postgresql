Description
===========

Installs and configures PostgreSQL as a client or a server.

Requirements
============

## Platforms

* Debian, Ubuntu
* Red Hat/CentOS/Scientific (6.0+ required) - "EL6-family"
* Fedora
* SUSE

Tested on:

* Ubuntu 10.04, 11.10, 12.04
* Red Hat 6.1, Scientific 6.1, CentOS 6.3

## Cookboooks

Requires Opscode's `openssl` cookbook for secure password generation.

Requires a C compiler and development headers in order to build the
`pg` RubyGem to provide Ruby bindings in the `ruby` recipe.

Opscode's `build-essential` cookbook provides this functionality on
Debian, Ubuntu, and EL6-family.

While not required, Opscode's `database` cookbook contains resources
and providers that can interact with a PostgreSQL database. This
cookbook is a dependency of database.

Attributes
==========

The following attributes are set based on the platform, see the
`attributes/default.rb` file for default values.

* `node['postgresql']['version']` - version of postgresql to manage
* `node['postgresql']['dir']` - home directory of where postgresql
  data and configuration lives.

* `node['postgresql']['client']['packages']` - An array of package names
  that should be installed on "client" systems.
* `node['postgresql']['server']['packages']` - An array of package names
  that should be installed on "server" systems.


The following attributes are generated in
`recipe[postgresql::server]`.

* `node['postgresql']['password']['postgres']` - randomly generated
  password by the `openssl` cookbook's library.
* `node['postgresql']['ssl']` - whether to enable SSL (off for version
  8.3, true for 8.4+).

Configuration
-------------

The `postgresql.conf` and `pg_hba.conf` files are dynamically
generated from attributes. Each key in `node['postgresql']['config']`
is a postgresql configuration directive, and will be rendered in the
config file. For example, the attribute:

    node['postgresql']['config']['listen_address'] = 'localhost'

Will result in the following line in the `postgresql.conf` file:

    listen_address = 'localhost'

The attributes file contains default values for Debian and RHEL
platform families (per the `node['platform_family']`). These defaults
have disparity between the platforms because they were originally
extracted from the postgresql.conf files in the previous version of
this cookbook, which differed in their default config. The resulting
configuration files will be the same as before, but the content will
be dynamically rendered from the attributes. The helpful commentary
will no longer be present. You should consult the PostgreSQL
documentation for specific configuration details.

The `pg_hba.conf` file is dynamically generated from the
`node['postgresql']['pg_hba']` attribute. This attribute must be an
array of hashes, each hash containing the authorization data. As it is
an array, you can append to it in your own recipes. The hash keys in
the array must be symbols. Each hash will be written as a line in
`pg_hba.conf`. For example, this entry from
`node['postgresql']['pg_hba']`:

    {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'}

Will result in the following line in `pg_hba.conf`:

    local all postgres  ident

Use `nil` if the CIDR-ADDRESS should be empty (as above).

Recipes
=======

default
-------

Includes the client recipe.

client
------

Installs the packages defined in the
`node['postgresql']['client']['packages']` attribute.

ruby
----

**NOTE** This recipe may not currently work when installing Chef with
  the
  ["Omnibus" full stack installer](http://opscode.com/chef/install) on
  some platforms due to an incompatibility with OpenSSL. See
  [COOK-1406](http://tickets.opscode.com/browse/COOK-1406). You can
  build from source into the Chef omnibus installation to work around
  this issue.

Install the `pg` gem under Chef's Ruby environment so it can be used
in other recipes. The build-essential packages and postgresql client
packages will be installed during the compile phase, so that the
native extensions of `pg` can be compiled.

server
------

Includes the `server_debian` or `server_redhat` recipe to get the
appropriate server packages installed and service managed. Also
manages the configuration for the server:

* generates a strong default password (via `openssl`) for `postgres`
* sets the password for postgres
* manages the `postgresql.conf` file.
* manages the `pg_hba.conf` file.

server\_debian
--------------

Installs the postgresql server packages and sets up the service. You
should include the `postgresql::server` recipe, which will include
this on Debian platforms.

server\_redhat
--------------

Manages the postgres user and group (with UID/GID 26, per RHEL package
conventions), installs the postgresql server packages, initializes the
database, and manages the postgresql service. You should include the
`postgresql::server` recipe, which will include this on RHEL/Fedora
platforms.

Resources/Providers
===================

See the [database](http://community.opscode.com/cookbooks/database)
for resources and providers that can be used for managing PostgreSQL
users and databases.

Usage
=====

On systems that need to connect to a PostgreSQL database, add to a run
list `recipe[postgresql]` or `recipe[postgresql::client]`.

On systems that should be PostgreSQL servers, use
`recipe[postgresql::server]` on a run list. This recipe does set a
password and expect to use it. It performs a node.save when Chef is
not running in `solo` mode. If you're using `chef-solo`, you'll need
to set the attribute `node['postgresql']['password']['postgres']` in
your node's `json_attribs` file or in a role.

License and Author
==================

- Author:: Joshua Timberman (<joshua@opscode.com>)
- Author:: Lamont Granquist (<lamont@opscode.com>)
- Author:: Chris Roberts (<chrisroberts.code@gmail.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
