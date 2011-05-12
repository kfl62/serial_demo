#encoding: utf-8
=begin
#IButton Database Hardware-Keys create statement#
=end

class CreateTableHwKeys < Sequel::Migration

  def up
    create_table(:hw_keys) do
      primary_key   :id
      foreign_key   :owner_id,   :prs_owners, :default => 1, :on_delete => :set_default, :on_update => :cascade
      column        :keyId,      String,      :size => 12
      column        :created_at, DateTime
      column        :updated_at, DateTime
    end
  end

  def down
    drop_table(:hw_keys)
  end

end

