#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Task model
      # ##Migration 0004_create_table_hw_tasks.rb
      #     def up
      #       create_table(:hw_devices) do
      #         primary_key :id
      #         column      :taskId,       Fixnum
      #         column      :name,          String,     :size => 20
      #         column      :created_at,    DateTime
      #         column      :updated_at,    DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:hw_tasks)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})
      # ##Associations
      #   *one_to_many* -> devices  {Ib::Db::Hw::Device}
      # @example On which devices is executed?
      #   t = Task.first
      #   t.devices         #> Array of {Ib::Db::Hw::Device} objects
      # @todo Document taskId's Integer(32bit) structure
      class Task < Sequel::Model
        set_dataset :hw_tasks
        plugin :timestamps

        one_to_many :devices
      end
    end
  end
end
