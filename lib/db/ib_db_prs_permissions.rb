#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Permission model#
      # ##Migration 0010_create_table_prs_permissions.rb##
      #     def up
      #       create_table(:prs_permissions) do
      #         primary_key   :id
      #         foreign_key   :group_id,          :prs_groups
      #         foreign_key   :request_node,      :hw_nodes
      #         foreign_key   :request_reader,    :hw_reader
      #         foreign_key   :response_node,     :hw_nodes
      #         foreign_key   :response_device,   :hw_devices
      #         column        :created_at,        DateTime
      #         column        :updated_at,        DateTime
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
        many_to_one :request_node,     :class => "Ib::Db::Hw::Node",  :key => :id
        many_to_one :request_reader,   :class => "Ib::Db::Hw::Reader",:key => :id
        many_to_one :response_node,    :class => "Ib::Db::Hw::Node",  :key => :id
        many_to_one :response_device,  :class => "Ib::Db::Hw::Device",:key => :id
        # @todo
        def validate
          validates_presence [:group, :request_node, :request_reader, :response_node, :response_device]
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
          ]
        end
        protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Persons::Permission id=#{id}",
                            :error => I18n.t('persons_permission.delete_message'))
        end
      end
    end
  end
end
