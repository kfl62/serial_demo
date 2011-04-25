#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Device model
      # ##Migration 0005_create_table_hw_devices.rb
      #     def up
      #       create_table(:hw_devices) do
      #         primary_key :id
      #         foreign_key :node_id,    :hw_nodes, :on_delete => :set_null, :on_update => :cascade
      #         foreign_key :task_id,    :hw_tasks, :on_delete => :set_null, :on_update => :cascade
      #         column      :name,       String,     :size => 20
      #         column      :created_at, DateTime
      #         column      :updated_at, DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:hw_devices)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations
      #   *many_to_one* -> node         {Ib::Db::Hw::Node}<br />
      #   *many_to_one* -> task         {Ib::Db::Hw::Task}<br />
      #   *one_to_many* -> permissions  {Ib::Db::Persons::Permission}
      # ##Validations
      #   TODO document validations
      # @example Connected to node?
      #   d = Device.first
      #   d.node.sid         #=> Integer connected node's sid
      # @example Associated task
      #   d = Device.first
      #   d.task.name        #=> String associated task's name
      # @example Permissions
      #   d = Device.first
      #   d.permissions      #> Array of {Ib::Db::Persons::Permission} objects
      class Device < Sequel::Model
        set_dataset :hw_devices
        plugin :timestamps
        plugin :validation_helpers

        many_to_one :node
        many_to_one :task
        one_to_many :permissions, :class => "Ib::Db::Persons::Permission", :key => :response_device
        class << self
          # Orphaned devices (does not belong to any node)
          # @return [Array]
          def orphans
            retval = []
            all.each{|r| retval << r if r.node_id.nil?}
            retval
          end
          # Free devices (has no task)
          # @return [Array]
          def free
            retval = []
            all.each{|r| retval << r if r.task_id.nil?}
            retval
          end
        end
        # @todo
        def validate
          validates_presence :name
          validates_max_length 20, :name, :allow_nil => true
        end
        # @todo
        # @return [Log::Error]
        def before_destroy
          delete_message
          super
        end
        # @return [Array of Hashes] one Hash for each column
        # @example Each hash contains:
        #   {
        #     :css   => "integer",        # style attribute for span|input tag
        #     :name  => "id",             # name attribute for span|input tag
        #     :label => I18n.t('mdl.id'), # localized title
        #     :value => id                # columns value
        #   }
        def table_data
          [
            {:css => "integer",:name => "id",:label => I18n.t('mdl.id'),:value => id},
            {:css => "integer",:name => "node_id",:label => I18n.t('hw_device.node_id'),:value => node_id},
            {:css => "integer",:name => "task_id",:label => I18n.t('hw_device.node_id'),:value => task_id},
            {:css => "normal",:name  => "name",:label => I18n.t('hw_device.name'),:value => name},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
       protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Hw::Device id=#{id}",
                            :error => I18n.t("hw_device.delete_message", :permissions => permissions.length))
        end
      end
    end
  end
end

