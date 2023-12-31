# Source: https://github.com/rails/rails/blob/v7.1.2/activerecord/lib/rails/generators/active_record/migration/templates/migration.rb.tt
class MvPostToNote < ActiveRecord::Migration[7.1]
  def change
    rename_table :posts, :notes
  end
end
