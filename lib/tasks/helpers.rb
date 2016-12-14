module Helpers
  def self.included(base)
    base.class_eval do
      no_tasks do
        # TODO:
        # - Create helper methods for validations

        def valid_file_location?(input)
          File.directory?(input)
        end

      end
    end
  end
end
