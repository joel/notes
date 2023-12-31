require "thor"

module PostCreation
  module Process
    class Rename < Thor
      def self.exit_on_failure?
        false
      end

      include Thor::Actions

      argument :old_name, type: :string
      argument :new_name, type: :string

      namespace "update"

      desc "name", "Run script to update the name of a resource"

      # bundle exec thor update:name old_name new_name
      def name
        # Define case-insensitive regular expression for old name
        say "Processing files and directories in #{Dir.pwd}"
        say "Renaming [#{old_name}] to [#{new_name}] in files and their content"
        old_name_regex = Regexp.new(old_name, Regexp::IGNORECASE)

        # Find and process files
        Dir.glob("**/*").each do |file_name|
          next unless File.file?(file_name)

          next if /assets/.match?(file_name)
          next if /tmp/.match?(file_name)

          new_content = File.read(file_name).gsub(old_name_regex) { |match| yield(match) }
          old_content = File.read(file_name)

          if new_content != old_content
            say "Updating content of file #{file_name}"
            File.open(file_name, 'w') { |file| file.write(new_content) }
          end
        end

        say_status("done", "Renamed #{old_name} to #{new_name} in files and their content", :green)
      end

    end
  end
end
