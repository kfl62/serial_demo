#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Permission model#
      # ##Migration 0010_create_table_prs_permissions.rb##
      #     def up
      #       create_table(:prs_permissions) do
      #         primary_key   :id
      #         foreign_key   :group_id,           :prs_groups
      #         foreign_key   :request_node_id,    :hw_nodes
      #         foreign_key   :request_reader_id,  :hw_reader
      #         foreign_key   :response_node_id,   :hw_nodes
      #         foreign_key   :response_device_id, :hw_devices
      #         column        :created_at,         DateTime
      #         column        :updated_at,         DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:prs_permissions)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations##
      #   *many_to_one* -> group           {Ib::Db::Persons::Group}<br />
      #   *many_to_one* -> request_node    {Ib::Db::Hw::Node}<br />
      #   *many_to_one* -> request_reader  {Ib::Db::Hw::Reader}<br />
      #   *many_to_one* -> response_node   {Ib::Db::Hw::Node}<br />
      #   *many_to_one* -> response_device {Ib::Db::Hw::Device}
      # ##Validations
      #   TODO document validations
      # @todo Document permissions mechanism and some examples
      class Permission < Sequel::Model
        set_dataset :prs_permissions
        plugin :timestamps
        plugin :validation_helpers

        many_to_one :group
        many_to_one :request_node,     :class => "Ib::Db::Hw::Node"
        many_to_one :request_reader,   :class => "Ib::Db::Hw::Reader"
        many_to_one :response_node,    :class => "Ib::Db::Hw::Node"
        many_to_one :response_device,  :class => "Ib::Db::Hw::Device"

        class << self
          # @todo document this method
          def new_record_defaults
            [
              {:css => "hidden",:name  => "group_id",:label => I18n.t('persons_permission.group'),:value => "nil"},
              {:css => "hidden",:name  => "request_node_id",:label => I18n.t('persons_permission.request_node'),:value => "nil"},
              {:css => "hidden",:name  => "request_reader_id",:label => I18n.t('persons_permission.request_reader'),:value => "nil"},
              {:css => "hidden",:name  => "response_node_id",:label => I18n.t('persons_permission.response_node'),:value => "nil"},
              {:css => "hidden",:name  => "response_device_id",:label => I18n.t('persons_permission.response_device'),:value => "nil"}
            ]
          end
          # @todo document this method
          def auto_search(e)
            permissions = []
            all do |p|
              label = "#{p.response_device.task.name rescue 'Unknown'} on #{p.response_node.name rescue 'Unknown'}"
              permissions << {:id => p.id,
                              :name => "permission",
                              :label => label,
                              :group_id => p.group_id,
                              :request_node_id => p.request_node_id,
                              :request_reader_id => p.request_reader_id ,
                              :response_node_id => p.response_node_id,
                              :response_device_id => p.response_device_id}
            end
            {:identifier => "id",:items => permissions}
          end
        end

        # @todo
        def validate
          #validates_presence [:group, :request_node, :request_reader, :response_node, :response_device]
        end
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
            {:css => "normal",:name  => "group_id",:label => I18n.t('persons_permission.group'),:value => (group.name rescue 'Undefined')},
            {:css => "normal",:name  => "request_node_id",:label => I18n.t('persons_permission.request_node'),:value => (request_node.name rescue 'Undefined')},
            {:css => "normal",:name  => "request_reader_id",:label => I18n.t('persons_permission.request_reader'),:value => (request_reader.name rescue 'Undefined')},
            {:css => "normal",:name  => "response_node_id",:label => I18n.t('persons_permission.response_node'),:value => (response_node.name rescue 'Undefined')},
            {:css => "normal",:name  => "response_device_id",:label => I18n.t('persons_permission.response_device'),:value => (response_device.name rescue 'Undefined')},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end

        def msg_request_node_sid
          retval = "%04d" % request_node.sid
          retval = retval[2,2] + retval[0,2]
          retval
        end

        def msg_request_reader_order
          "%02d" % request_reader.order
        end

        def msg_response_node_sid
          retval = "%04d" % response_node.sid
          retval = retval[2,2] + retval[0,2]
          retval
        end

        def msg_response_device_order
          "%02d" % response_device.order
        end

        def msg_response_device_taskId
          "%08d" % response_device.task.taskId.to_s(16)
        end

        protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Persons::Permission id=#{id}",
                            :error => I18n.t('crud.log.delete'))
        end
      end
    end
  end
end
