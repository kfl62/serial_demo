#encoding: utf-8
=begin
#IButton Database Hardware-Devices create statement#
=end

class CreateTableHwDevices < Sequel::Migration

  def up
    create_table(:hw_devices) do
      primary_key   :id
      foreign_key   :node_id,    :hw_nodes, :on_delete => :cascade,  :on_update => :cascade
      column        :order,      Fixnum,    :size => 4,   :default => 1
      foreign_key   :task_id,    :hw_tasks, :on_delete => :set_null, :on_update => :cascade
      column        :name,       String,    :size => 20
      column        :created_at, DateTime
      column        :updated_at, DateTime
    end
  end

  def down
    drop_table(:hw_devices)
  end

end

