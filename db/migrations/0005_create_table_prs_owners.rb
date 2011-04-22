#encoding: utf-8
=begin
#IButton Database Persons-Owner create statement#
=end

class CreateTablePrsOwners < Sequel::Migration

  def up
    create_table('prs_owners') do
      primary_key   :id
      foreign_key   :key_id,              :hw_keys
      column        :first_name,          String
      column        :last_name,           String
      column        :created_at,          DateTime
      column        :updated_at,          DateTime
    end
  end

  def down
    drop_table(:prs_owners)
  end
  
end

