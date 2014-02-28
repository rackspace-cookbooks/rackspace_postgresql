# Cookbook Name:: rackspace_postgresql
# Library:: default
# Author:: David Crane (<davidc@donorschoose.org>)
# Author:: Matthew Thode (<matt.thode@rackspace.org>)
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

include Chef::Mixin::ShellOut

module Format
  ########
  # a simple Format module for config files
  def format_postgresql_config(hash)
    ########
    # Spits out a list of strings to put in a config
    _ = []
    hash.sort.map do |key, value|
      unless value.to_s.empty?
        value = case value
        when TrueClass
          'on'
        when FalseClass
          'off'
        else
          value.to_s
        end
        _ << "#{key} = #{value}"
      end
    end
    _
  end
  # End the Format module
end
