module Helpers
  def self.included(base)
    base.class_eval do
      no_tasks do
        # TODO:
        # - Create helper methods for validations

        def valid_file_location?(input)
          File.directory?(input)
        end

        def valid_configurations?(input)
          # approved = Dir.entries("examples/").select {|entry| File.directory? File.join("examples/",entry) and !(entry =='.' || entry == '..') }
          approved =
          Dir.entries("examples/").select do |entry|
            File.directory? File.join("examples/",entry) and !(entry =='.' || entry == '..')
          end
          if approved.include? input
            return true
          else
            puts "Only the following configurations are available:"
            puts approved.each { |e| e }
          end
        end

        def validate_user_input(question, answer, proceed)
          say(question, :yellow)
          exit unless proceed.include? ask(answer, :bold)
        end

      end
    end
  end
end
