#encoding: utf-8
=begin
#IButton Database Persons-Admins create statement#
=end

class CreateTablePrsAdmins < Sequel::Migration

  def up
    create_table('prs_admins') do
      primary_key   :id
      foreign_key   :owner_id,        :prs_owners, :on_delete => :cascade, :on_update => :cascade
      column        :login_name,      String,      :size => 20
      column        :email,           String,      :size => 50
      column        :salt,            String
      column        :hashed_password, String
      column        :created_at,      DateTime
      column        :updated_at,      DateTime
    end
  end

  def down
    drop_table(:prs_admins)
  end

end

