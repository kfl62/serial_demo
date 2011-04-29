#encoding: utf-8
=begin
#IButton Database Persons-Permissions create statement#
=end

class CreateTablePrsPermissions < Sequel::Migration

  def up
    create_table(:prs_permissions) do
      primary_key   :id
      foreign_key   :group_id,           :prs_groups, :on_delete => :cascade, :on_update => :cascade
      foreign_key   :request_node_id,    :hw_nodes,   :on_delete => :cascade, :on_update => :cascade
      foreign_key   :request_reader_id,  :hw_readers, :on_delete => :cascade, :on_update => :cascade
      foreign_key   :response_node_id,   :hw_nodes,   :on_delete => :cascade, :on_update => :cascade
      foreign_key   :response_device_id, :hw_devices, :on_delete => :cascade, :on_update => :cascade
      column        :created_at,         DateTime
      column        :updated_at,         DateTime
    end
  end

  def down
    drop_table(:prs_permissions)
  end

end

