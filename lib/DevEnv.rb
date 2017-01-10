require "rubygems"
require "bundler"
require "thor"
require "fileutils"
require "yaml"
require "vagrant-wrapper"
Bundler.setup

Dir[File.expand_path(File.dirname(__FILE__) + "/tasks/*.rb")].each do |file|
  require file
end

class CLI < Thor
  # shared_options = [
  #   :opt1, {:type => :string, :required => true},
  #   :opt2, {:type => :string, :required => true},
  #   :opt3, {:type => :string, :required => true},
  # ]
  include Helpers
  include Vagrant
end
