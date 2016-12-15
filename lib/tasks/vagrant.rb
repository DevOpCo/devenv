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

    end
  end
end
