module Vagrant
  def self.included(base)
    base.class_eval do
      desc "vagrant [options]", "vagrant command"
      option :command, :type => :string, :aliases => "-c"
      option :setup, :type => :string, :aliases => "-s"
      option :provision, :type => :string, :aliases => "-p"
      long_desc <<-LONGDESC
      Runs vagrant and allows for setup through examples directories
      LONGDESC
      def vagrant
        puts "Copies files from examples into config and runs vagrant"
      end
    end
  end
end
