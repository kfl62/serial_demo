#encoding: utf-8
=begin
#IButton Database Hardware-Tasks create statement#
=end

class CreateTableHwTasks < Sequel::Migration

  def up
    create_table(:hw_tasks) do
      primary_key   :id
      column        :taskId,              Fixnum
      column        :name,                String,     :size => 20
      column        :created_at,          DateTime
      column        :updated_at,          DateTime
    end
  end

  def down
    drop_table(:hw_tasks)
  end

end

