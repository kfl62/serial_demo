#encoding: utf-8
=begin
#IButton Database Hardware-Readers create statement#
=end

class CreateTableHwReaders < Sequel::Migration

  def up
    create_table(:hw_readers) do
      primary_key   :id
      foreign_key   :node_id,    :hw_nodes, :on_delete => :cascade, :on_update => :cascade
      column        :order,      Fixnum,    :size => 4,   :default => 1
      column        :name,       String,    :size => 20
      column        :created_at, DateTime
      column        :updated_at, DateTime
    end
  end

  def down
    drop_table(:hw_readers)
  end

end

