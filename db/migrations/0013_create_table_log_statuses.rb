#encoding: utf-8
=begin
#IButton Database Log-Statuses join table create statement#
=end

class CreateTableLogStatuses < Sequel::Migration

  def up
    create_table('log_statuses') do
      primary_key :id
      column      :created_at, DateTime
      column      :node_id,    Fixnum
      column      :node,       String,     :size => 20
      column      :updated_at, DateTime
    end
  end

  def down
    drop_table(:log_statuses)
  end

end