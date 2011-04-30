#encoding: utf-8
=begin
#IButton Database Hardware-Nodes create statement#
=end

class CreateTableHwNodes < Sequel::Migration

  def up
    create_table(:hw_nodes) do
      primary_key   :id
      column        :sid,               Fixnum,                 :default => 2046
      column        :sid_at,            DateTime
      column        :name,              String,     :size => 20,:default => "New node"
      column        :readers_nr,        Fixnum,     :size => 2
      column        :devices_nr,        Fixnum,     :size => 2
      column        :created_at,        DateTime
      column        :updated_at,        DateTime
    end
  end

  def down
    drop_table(:hw_nodes)
  end

end

