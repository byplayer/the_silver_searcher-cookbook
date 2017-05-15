include_recipe 'chef-sugar'
include_recipe 'build-essential'

if debian?
  prereqs = %w(automake pkg-config zlib1g-dev libpcre3-dev liblzma-dev)
elsif rhel? || fedora?
  prereqs = %w(automake pkgconfig zlib zlib-devel pcre pcre-devel xz xz-devel)
else
  log "Don't know prereqs for #{node['platform_family']}; proceeding anyway"
  prereqs = []
end

prereqs.each do |pkg|
  package pkg do
    action :install
  end
end

cache = "the_silver_searcher-#{node['the_silver_searcher']['version']}"

remote_file "#{Chef::Config['file_cache_path']}/#{cache}.tar.gz" do
  source node['the_silver_searcher']['url']
  checksum node['the_silver_searcher']['checksum']
  notifies :run, 'bash[install ag]', :immediately
end

bash 'install ag' do
  user 'root'
  cwd Chef::Config['file_cache_path']
  code <<-EOH
    tar -zxf #{cache}.tar.gz
    (cd #{cache} && ./build.sh #{node['the_silver_searcher']['build_opt']} && make install)
  EOH
  action :nothing
end
