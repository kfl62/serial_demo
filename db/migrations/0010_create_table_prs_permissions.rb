#encoding: utf-8
=begin
#IButton Database Persons-Permissions create statement#
=end

class CreateTablePrsPermissions < Sequel::Migration

  def up
    create_table(:prs_permissions) do
      primary_key   :id
      foreign_key   :group_id,          :prs_groups
      foreign_key   :request_node,      :hw_nodes
      foreign_key   :request_reader,    :hw_readers
      foreign_key   :response_node,     :hw_nodes
      foreign_key   :response_device,   :hw_devices
      column        :created_at,        DateTime
      column        :updated_at,        DateTime
    end
  end

  def down
    drop_table(:prs_permissions)
  end

end

