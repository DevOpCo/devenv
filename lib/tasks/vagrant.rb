module Vagrant
  def self.included(base)
    base.class_eval do
      desc "configure [options]", "configures vagrant boxes from an example directory"
      option :example, :type => :string, :aliases => "-e"
      long_desc <<-LONGDESC
      Setups up vagrant through examples directories as specified

      configure -e <example_directory>
      LONGDESC
      def configure
        valid=valid_configurations?(options[:example])
        if valid
          if !(Dir.entries('config/') - %w{ . .. .gitkeep }).empty?
            question="Caution! Configuration Exist in Directory"
            answer='Proceed Anyway?'
            proceed=["Y","Yes","yes","y"]
            validate_user_input(question, answer, proceed)
          end
          Dir.glob("examples/#{options[:example]}/*.yml").each do |cp|
            FileUtils.cp_r(cp, 'config/')
          end
          puts "Configurations copied from the #{options[:example]} examples"
        else
          valid
        end
      end

      desc "dependencies", "checks for system dependencies"
      long_desc <<-LONGDESC
      Runs a check to verify system dependencies are met
      LONGDESC
      def dependencies
        packages=['vagrant', 'virtualbox']
        missing=[]
        packages.each do |e|
          missing << e unless check_dependencies(e)
        end
        if !missing.empty?
          puts "You are missing the following packages:"
          puts missing.each { |e| e }
        else
          puts "Dependencies are installed"
        end
      end

      desc "vagrant [options]", "runs vagrant commands"
      option :status, :type => :string, :aliases => "-s"
      option :resume, :type => :string, :aliases => "-r"
      option :provision, :type => :string, :aliases => "-p"
      long_desc <<-LONGDESC
      Runs vagrant up by default, ensures puppet and config repos are in place

      This is an optional vagrant runner, intended for comprehensibility,
      it exchanges simplicity of code for simplicity of use, implementing a semantic
      abstraction layer over vagrant's already simple cli interface.
      LONGDESC
      def vagrant
        if options[:status]
          status = VagrantWrapper.new.get_output("status").gsub(/Organization is not set\nCurrent machine states:\n\n|\n\nThis environment represents multiple VMs. The VMs are all listed\nabove with their current state. For more information about a specific\nVM, run `vagrant status NAME`.\n/ ,'').split("\n").each {|a| a.gsub!(/([ ]{2,})/,',')}
          h=[]
          status.each {|s| h << Hash[ [:server_name, :server_status].zip(s.split(',')) ]}
          h.map {|n| puts "#{n[:server_name]}: #{n[:server_status]}"}
        elsif options[:provision]
          puts VagrantWrapper.new.get_output("provision")
        else
          puts VagrantWrapper.new.get_output("up")
        end
      end

    end
  end
end
