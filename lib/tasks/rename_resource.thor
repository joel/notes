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
          next if /assets/.match?(file_name)
          next if /tmp/.match?(file_name)
          next unless File.file?(file_name)
          # say "Processing file #{file_name}"

          # Rename file if it contains the old name
          # new_file_name = file_name.gsub(old_name_regex) { |match| match_case(match, new_name) }

          # if file_name != new_file_name
          #   say "Renaming file #{file_name} to #{new_file_name}"
          #   FileUtils.mv(file_name, new_file_name)
          # end

          new_content = content = File.read(file_name).gsub(old_name_regex) { |match| yield(match) }
          old_content = File.read(file_name)

          if new_content != old_content
            say "Updating content of file #{file_name}"
            File.open(file_name, 'w') { |file| file.write(new_content) }
          end

          # Update content
          # gsub_file new_file_name, old_name_regex do |match|
          #   match_case(match, new_name)
          # end

          # content = File.read(file_name).gsub(regexp) { |match| yield(match) }

          # if gsub_file
        end

        # Find and process directories
        # Dir.glob("**/*").each do |file_name|
        #   next if /assets/.match?(file_name)
        #   next if /tmp/.match?(file_name)
        #   next if File.file?(file_name)
        #   # say "Processing directory #{file_name}"

        #   # Rename file if it contains the old name
        #   new_file_name = file_name.gsub(old_name_regex) { |match| match_case(match, new_name) }
        #   FileUtils.mv(file_name, new_file_name) if file_name != new_file_name
        # end

        say_status("done", "Renamed #{old_name} to #{new_name} in files and their content", :green)
      end

      private

      # Helper method to replace content in a file
      def gsub_file(file_name, regexp)
        content = File.read(file_name).gsub(regexp) { |match| yield(match) }
        File.open(file_name, 'w') { |file| file.write(content) }
      end

      # Match the case of the old name with the new name
      def match_case(old, new_name)
        old == old.downcase ? new_name.downcase : new_name.capitalize
      end

    end
  end
end
