#encoding: utf-8
=begin
#IButton Database Log-Errors join table create statement#
=end

class CreateTableLogErrors < Sequel::Migration

  def up
    create_table('log_errors') do
      primary_key :id
      column      :created_at, DateTime
      column      :from,       String
      column      :error,      String
    end
  end

  def down
    drop_table(:log_errors)
  end

end