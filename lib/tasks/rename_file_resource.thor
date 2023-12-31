require "thor"

module PostCreation
  module Process
    class RenameFile < Thor
      def self.exit_on_failure?
        false
      end

      include Thor::Actions

      argument :old_name, type: :string
      argument :new_name, type: :string

      namespace "update"

      desc "file", "Run script to update the name of a resource"

      # bundle exec thor update:file old_name new_name
      def file
        # Define case-insensitive regular expression for old name
        say "Processing files and directories in #{Dir.pwd}"
        say "Renaming [#{old_name}] to [#{new_name}] in files and their content"
        old_name_regex = Regexp.new(old_name, Regexp::IGNORECASE)

        # Find and process files
        Dir.glob("**/*").each do |file_name|
          next unless File.file?(file_name)

          next if /assets/.match?(file_name)
          next if /tmp/.match?(file_name)

          # Rename file if it contains the old name
          new_file_name = file_name.gsub(old_name_regex) { |match| match_case(match, new_name) }

          # Ensure the target directory exists before moving the file
          ensure_directory_exists(new_file_name)

          if file_name != new_file_name
            say "Renaming file #{file_name} to #{new_file_name}"

            FileUtils.mv(file_name, new_file_name)
          end
        end

        say_status("done", "Renamed #{old_name} to #{new_name} in files and their content", :green)
      end

      private

      # Match the case of the old name with the new name
      def match_case(old, new_name)
        old == old.downcase ? new_name.downcase : new_name.capitalize
      end

      def ensure_directory_exists(file_path)
        dirname = File.dirname(file_path)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      end
    end
  end
end
