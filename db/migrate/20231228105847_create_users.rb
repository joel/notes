# Source: https://github.com/rails/rails/blob/v7.1.2/activerecord/lib/rails/generators/active_record/migration/templates/create_table_migration.rb.tt
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
