#encoding: utf-8
=begin
#IButton Database Persons-Admins create statement#
=end

class CreateTablePrsAdmins < Sequel::Migration

  def up
    create_table('prs_admins') do
      primary_key   :id
      foreign_key   :owner_id,            :prs_owners
      column        :login_name,          String
      column        :email,               String
      column        :salt,                String
      column        :hashed_password,     String
      column        :created_at,          DateTime
      column        :updated_at,          DateTime
    end
  end

  def down
    drop_table(:prs_admins)
  end

end

