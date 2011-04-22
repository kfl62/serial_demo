#encoding: utf-8
=begin
#IButton Database Hardware-Device create statement#
=end

class CreateTableHwDevices < Sequel::Migration

  def up
    create_table(:hw_devices) do
      primary_key   :id
      foreign_key   :node_id,             :hw_nodes
      column        :name,                String
      column        :order,               String,       :size => 2
      column        :created_at,          DateTime
      column        :updated_at,          DateTime
    end
  end

  def down
    drop_table(:hw_devices)
  end

end

