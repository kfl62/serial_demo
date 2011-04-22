#encoding: utf-8
=begin
#IButton Database Hardware-Key create statement#
=end

class CreateTableHwKeys < Sequel::Migration

  def up
    create_table(:hw_keys) do
      primary_key   :id
      column        :keyId,             String,     :size => 12,  :unique => true
      column        :created_at,        DateTime
      column        :updated_at,        DateTime
    end
  end

  def down
    drop_table(:hw_keys)
  end

end

