require "thor"

module PostCreation
  module Process
    class Cmd < Thor
      def self.exit_on_failure?
        false
      end

      include Thor::Actions

      namespace "update"

      desc "app", "Run script to update the app"

      # bundle exec thor update:app
      def app
        run("rails g scaffold user name:string --force")
        commit "Add scaffold user"

        run("rails g scaffold post title:string body:text user:references --force")
        commit "Add scaffold post"

        run_with_clean_bundler_env("SKIP=RailsSchemaUpToDate,LocalPathsInGemfile git apply ../after_create/patches/posts_controller.rb.patch")
        commit "Update posts controller"

        run_with_clean_bundler_env("SKIP=RailsSchemaUpToDate,LocalPathsInGemfile git apply ../after_create/patches/user.rb.patch")
        commit "Update user model"

        run_with_clean_bundler_env("SKIP=RailsSchemaUpToDate,LocalPathsInGemfile git apply ../after_create/patches/_post_partial.html.erb.patch")
        commit "Update post partial"

        output = `rails runner 'puts ActiveRecord::Base.connection.adapter_name'`
        if output.strip != "PostgreSQL"
          run_with_clean_bundler_env("SKIP=RailsSchemaUpToDate,LocalPathsInGemfile git apply ../after_create/patches/post_model.rb.patch")
          commit "Update post model"
        end

        append_to_file "db/seeds.rb", <<~RUBY
          User.find_or_create_by!(name: "John Doe")
        RUBY
        commit "Seed content"

        # run("rails db:drop db:create db:migrate db:seed db:schema:dump")
        run("rails db:drop db:create db:migrate db:seed")
        if output.strip == "Mysql2"
          current_directory_name = File.basename(Dir.pwd)
          say "Creating MySQL databases for #{current_directory_name}_development and #{current_directory_name}_test"
          run("docker exec mysql-container bash -c \"mysql -u root -e 'CREATE DATABASE IF NOT EXISTS #{current_directory_name}_development;'\"")
          run("docker exec mysql-container bash -c \"mysql -u root -e 'CREATE DATABASE IF NOT EXISTS #{current_directory_name}_test;'\"")
        else
          commit "Update Schema"
        end

        run("cp ../after_create/deployment_configuration.thor lib/tasks/deployment_configuration.thor")
        commit "Add deployment configuration"

        say "bundle exec thor deployment:configuration"

        # run("rails s")
        run("bundle exec thor deployment:configuration")
      end

      private

      def commit(message)
        run("rubocop -A")
        run("rubocop --regenerate-todo")
        run_with_clean_bundler_env("SKIP=RailsSchemaUpToDate,LocalPathsInGemfile overcommit --run")
        run_with_clean_bundler_env("SKIP=RailsSchemaUpToDate,LocalPathsInGemfile git add .")
        if run_with_clean_bundler_env("SKIP=RailsSchemaUpToDate,LocalPathsInGemfile git commit -m '#{message}'")
          puts "✅ Git commit successful."
        else
          puts "❌ Git commit failed."
        end
      end

      def run_with_clean_bundler_env(cmd)
        success = if defined?(Bundler)
                    if Bundler.respond_to?(:with_original_env)
                      Bundler.with_original_env { run(cmd) }
                    else
                      Bundler.with_clean_env { run(cmd) }
                    end
                  else
                    run(cmd)
                  end

        return true if success

        puts "Command failed, exiting: #{cmd}"
        exit(1)
      end
    end
  end
end
