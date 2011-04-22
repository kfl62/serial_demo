#encoding: utf-8
=begin
#IButton Database Hardware-Reader create statement#
=end

class CreateTableHwReaders < Sequel::Migration

  def up
    create_table(:hw_readers) do
      primary_key   :id
      foreign_key   :node_id,             :hw_nodes
      column        :name,                String
      column        :order,               String,       :size => 2
      column        :created_at,          DateTime
      column        :updated_at,          DateTime
    end
  end

  def down
    drop_table(:hw_readers)
  end

end

