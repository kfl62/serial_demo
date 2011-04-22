#encoding: utf-8
=begin
#IButton Database Hardware-Node create statement#
=end

class CreateTableHwNodes < Sequel::Migration

  def up
    create_table(:hw_nodes) do
      primary_key   :id
      column        :sid,               String,     :size => 4, :default => "2046"
      column        :sid_at,            DateTime
      column        :name,              String
      column        :readers_nr,        Fixnum,     :size => 2
      column        :devices_nr,        Fixnum,     :size => 2
      column        :answer_status,     TrueClass,              :default => false
      column        :created_at,        DateTime
      column        :updated_at,        DateTime
    end
  end

  def down
    drop_table(:hw_nodes)
  end

end

