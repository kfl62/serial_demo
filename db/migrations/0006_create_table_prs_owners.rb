#encoding: utf-8
=begin
#IButton Database Persons-Owners create statement#
=end

class CreateTablePrsOwners < Sequel::Migration

  def up
    create_table('prs_owners') do
      primary_key   :id
      column        :first_name, String,   :size => 20
      column        :last_name,  String,   :size => 20
      column        :created_at, DateTime
      column        :updated_at, DateTime
    end
  end

  def down
    drop_table(:prs_owners)
  end

end

