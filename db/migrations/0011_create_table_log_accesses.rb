#encoding: utf-8
=begin
#IButton Database Log-Accesses join table create statement#
=end

class CreateTableLogAccesses < Sequel::Migration

  def up
    create_table('log_accesses') do
      primary_key :id
      column      :created_at, DateTime
      column      :owner_id,   Fixnum
      column      :owner,      String,     :size => 40
      column      :node_req,   String,     :size => 20
      column      :reader,     String,     :size => 20
      column      :node_res,   String,     :size => 20
      column      :device,     String,     :size => 20
      column      :task,       String,     :size => 40
      column      :status,     TrueClass, :default => true
    end
  end

  def down
    drop_table(:log_accesses)
  end

end