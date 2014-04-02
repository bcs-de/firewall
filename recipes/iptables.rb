#
# Cookbook Name:: firewall
# Recipe:: iptables
#
# Copyright 2012, computerlyrik
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
package "iptables"

[:ubuntu, :debian].each do |platform|
  Chef::Platform.set(
    :platform => platform,
    :resource => :firewall,
    :provider => Chef::Provider::FirewallIptables
  )
  Chef::Platform.set(
    :resource => :firewall_rule,
    :provider => Chef::Provider::FirewallRuleIptables
  )
end

package 'iptables-persistent'

service 'iptables-persistent' do
  action :enable
end

execute 'save iptables rules' do
  command 'iptables-save > /etc/iptables/rules.v4'
  action :nothing
end

template '/etc/sysctl.d/ip_forward.conf' do
  source 'sysctl_ipforward.erb'
  variables(
    ipv4_forwarding: true,
    ipv6_forwarding: false
  )
end

execute 'sysctl net.ipv4.ip_forward=1' do
  only_if 'sysctl net.ipv4.ip_forward |grep 0'
end
