# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

# Set Constants
ROOT_DIR = '.'

# For initial vagrant up, run ORGANIZATION=<organization> vagrant up
# The repos listed in the repos.yml will be cloned into this directory.
# Clones via git protocol, not https - ensure your keys are set
# This is currently written and tested with Github in mind TODO: make more extensible
org = ENV.fetch('ORGANIZATION', nil)
repo = YAML.load_file('config/repos.yml')
remote_repo_root = repo['remote_repo_root']
org_root = ( repo['default']['org_root'] if org.nil?) || repo[org.downcase]['org_root']
repos = ( repo['default']['repos'] if org.nil?) || repo[org.downcase]['repos']+repo['default']['repos']
puts "Organization is "+ (ENV['ORGANIZATION'] || "not set")
if ARGV[-1] == "up"
  repos.each do |d|
    unless Dir.exists?(File.join('..',"#{d}"))
      repo_check=Dir.exists?(File.join('..',"#{d}"))
      puts "Checking if repo already exists #{repo_check}"
      puts "cloning #{d}...."
      puts `git clone #{remote_repo_root}:#{org_root}/#{d}.git ../#{d}`
    end
  end
end

# Load Settings and Configurations
plugins = YAML.load_file('config/plugins.yml')
required_plugins = plugins['plugins']['default'] + plugins['plugins']['user']
plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  p "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

aws_credentials = {
  my_aws_access_key_id: '<No Credentials>',
  my_aws_secret_access_key: '<No Credentials>'
}
if ( credentials = Aws::SharedCredentials.new.credentials )
  aws_credentials[:my_aws_access_key_id] = credentials.access_key_id
  aws_credentials[:my_aws_secret_access_key] = credentials.secret_access_key
end

AutoNetwork.default_pool = '192.168.100.0/24'

config = YAML.load_file(File.join(__dir__,'config', 'servers.yml'))
servers = config[:servers]

Vagrant.configure(2) do |config|
  servers.each do |machine|
    config.vm.define machine[:name] do |node|
      node.vm.box = machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", :auto_network => true
      node.vm.provider "virtualbox" do |vb|
        # vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.cpus = machine[:cpus]
        vb.memory = machine[:ram]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", machine[:natdnsproxy1]]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", machine[:natdnshostresolver1]]
      end

      sync_type = RbConfig::CONFIG['host_os'] =~ /mswin|windows|cygwin|mingw/i ? 'smb' : 'nfs'
      sync_dirs = [
        { source: '.', target: '/vagrant', disabled: true },
      ]

      if machine[:hiera_dir]
        sync_dirs << {
          source: machine[:hiera_dir],
          target: '/host/hieradata'
        }
      end

      if machine[:sync_rvm]
        rvm_sync_dir = File.join(ROOT_DIR, '.rvm-vagrant-sync', machine[:name])

        unless File.exists?(File.join('.vagrant', 'machines', machine[:name], 'virtualbox', 'id'))
          Dir[File.join(rvm_sync_dir, '*')].each do |dir|
            FileUtils.rm_rf(dir)
          end
        end

        FileUtils.mkdir(rvm_sync_dir) unless File.directory?(rvm_sync_dir)
        sync_dirs << {
          source: rvm_sync_dir,
          target: '/usr/local/rvm'
        }
      end

      if machine[:sync_apps]
        Array(machine[:sync_apps]).each do |app_name|
          Dir.glob(File.join(ROOT_DIR, '..', app_name)).each do |app|
            next if %w( platform-development ).include?(File.basename(app))
            sync_dirs << {
              source: app,
              target: "/opt/#{File.basename(app)}/current"
            }
          end
        end
      end

      sync_dirs.each do |sync|
        node.vm.synced_folder(sync[:source], sync[:target], type: sync_type, disabled: sync.fetch(:disabled, false))
      end

      if machine[:provisioners]
        type=machine[:provisioners]
        type.each do |t|
          if t[:type] == 'inline'
            node.vm.provision 'shell', inline: t[:script]
          elsif t[:type] == 'path'
            node.vm.provision 'shell', path: t[:script]
          elsif t[:type] == 'puppet'
            node.vm.provision "puppet" do |puppet|
              puppet.facter = {
                "organization" => ENV['ORGANIZATION'] || t[:puppet_facters][:organization],
                "client" => t[:puppet_facters][:client],
                "env" => t[:puppet_facters][:env],
                "role" => t[:puppet_facters][:role],
                "sub_role" => t[:puppet_facters][:sub_role],
                "environment" => ENV['PUPPET_ENV'] || t[:puppet_facters][:puppet_environment],
              }
              puppet.module_path = t[:puppet_paths][:modules_dir]
              puppet.manifests_path = t[:puppet_paths][:manifests_path]
              puppet.manifest_file  = t[:puppet_paths][:manifest_file]
              puppet.hiera_config_path = t[:puppet_paths][:hiera_config_file]
              puppet.options = [ "#{%w(1 true).include?(ENV['DEBUG'])? '--debug' : ''} --verbose --show_diff  --environment=#{ENV['PUPPET_ENV'] || t[:puppet_facters][:puppet_environment]} #{%w(1 true).include?(ENV['TRACE'])? '--trace' : ''}" ]
              puppet.synced_folder_type = sync_type
            end
          end
        end
      end

    end
  end
end
