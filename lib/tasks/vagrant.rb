module Vagrant
  def self.included(base)
    base.class_eval do
      desc "configure [options]", "configure command"
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

      desc "dependencies", "dependencies command"
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

    end
  end
end
