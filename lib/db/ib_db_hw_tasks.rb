#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Task model
      # ##Migration 0004_create_table_hw_tasks.rb
      #     def up
      #       create_table(:hw_devices) do
      #         primary_key :id
      #         column      :taskId,     Fixnum
      #         column      :name,       String,     :size => 20
      #         column      :created_at, DateTime
      #         column      :updated_at, DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:hw_tasks)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations
      #   *one_to_many* -> devices  {Ib::Db::Hw::Device}
      # ##Validations
      #   TODO document validations
      # @example On which devices is executed?
      #   t = Task.first
      #   t.devices         #> Array of {Ib::Db::Hw::Device} objects
      # @todo Document taskId's Integer(32bit) structure
      class Task < Sequel::Model
        set_dataset :hw_tasks
        plugin :timestamps
        plugin :validation_helpers

        one_to_many :devices
        class << self
           def new_record_defaults
            [
              {:css => "hidden",:name  => "taskId",:label => I18n.t('hw_task.taskId'),:value => 1},
              {:css => "normal",:name  => "name",:label => I18n.t('hw_task.name'),:value => "New Task"}
            ]
          end
         # @todo document this method
          def auto_search(e)
            tasks = [:id => "0",:name => "Remove Task",:label => "<span class='warning'>Remove selected</span>"]
            all do |t|
              tasks << {:id => t.id,:name => t.name,:label => "#{t.name} #{t.devices.empty? ? ' | has no Devices' : ''}"}
            end
            {:identifier => "id",:items => tasks}
          end
        end
        # @todo
        def validate
          validates_presence [:name, :taskId]
          validates_max_length 20, :name, :allow_nil => true
          validates_integer :taskId, :allow_nil => true
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
            {:css => "integer",:name => "taskId",:label => I18n.t('hw_task.taskId'),:value => taskId},
            {:css => "normal",:name  => "name",:label => I18n.t('hw_task.name'),:value => name},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
       protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Hw::Task id=#{id}",
                            :error => I18n.t("hw_task.delete_message", :devices => devices.length))
        end
      end
    end
  end
end
