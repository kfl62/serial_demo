#encoding: utf-8
=begin
#IButton Database Persons-Groups create statement#
=end

class CreateTablePrsGroups < Sequel::Migration

  def up
    create_table('prs_groups') do
      primary_key   :id
      column        :name,           String,     :size => 20
      column        :created_at,     DateTime
      column        :updated_at,     DateTime
    end
  end

  def down
    drop_table(:prs_groups)
  end

end