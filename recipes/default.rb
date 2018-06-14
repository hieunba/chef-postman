#
# Cookbook:: postman
# Recipe:: default
#
# Copyright:: 2018, Nghiem Ba Hieu
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

opt_dir = '/opt'
postman_dl_path = ::File.join(Chef::Config[:file_cache_path], 'postman.tar.gz')

run = Mixlib::ShellOut.new('which postman').run_command
postman_installed = run.stderr.empty? && (run.stdout =~ /postman/)

directory opt_dir do
  owner 'root'
  group 'root'
  mode 0o755
  action :create
end

remote_file postman_dl_path do
  source node['postman']['download_url']
  action :create
  not_if { postman_installed }
end

execute 'install Postman' do
  cwd Chef::Config[:file_cache_path]
  command "tar xf postman.tar.gz -C #{opt_dir}"
  not_if { postman_installed }
end

link '/usr/bin/postman' do
  to ::File.join(opt_dir, 'Postman', 'Postman')
end

file "#{opt_dir}/Postman/postman.desktop" do
  content <<DESKTOP
  [Desktop Entry]
  Encoding=UTF-8
  Name=Postman
  Exec=postman
  Icon=#{opt_dir}/Postman/app/resources/app/assets/icon.png
  Terminal=false
  Type=Application
  Categories=Development
DESKTOP
  owner 'root'
  group 'root'
  mode 0o755
end

link '/usr/share/applications/postman.desktop' do
  to "#{opt_dir}/Postman/postman.desktop"
end

file postman_dl_path do
  action :delete
end
