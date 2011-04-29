#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Node model
      # ##Migration 0002_create_table_hw_nodes.rb
      #     def up
      #       create_table(:hw_nodes) do
      #         primary_key :id
      #         column      :sid,           String,     :size => 4, :default => "2046"
      #         column      :sid_at,        DateTime
      #         column      :name,          String,     :size => 20
      #         column      :readers_nr,    Fixnum,     :size => 2
      #         column      :devices_nr,    Fixnum,     :size => 2
      #         column      :created_at,    DateTime
      #         column      :updated_at,    DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:hw_nodes)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations
      #   *one_to_many* -> readers              {Ib::Db::Hw::Reader}<br />
      #   *one_to_many* -> devices              {Ib::Db::Hw::Device}<br />
      #   *one_to_many* -> request_permissions  {Ib::Db::Persons::Permission}<br />
      #   *one_to_many* -> response_permissions {Ib::Db::Persons::Permission}
      # ##Validations
      #   TODO document validations
      # @example Connected readers/devices
      #   n = Node.first
      #   n.readers         #=> Array of connected readers
      #   n.devices.length  #=> Integer the count of connected devices
      # @example Permissions
      #   n = Node.first
      #   n.request_permissions   #> Array of {Ib::Db::Persons::Permission} objects
      #   n.response_permissions  #> Array of {Ib::Db::Persons::Permission} objects
      class Node < Sequel::Model
        set_dataset :hw_nodes
        plugin :timestamps
        plugin :validation_helpers

        one_to_many :readers
        one_to_many :devices
        one_to_many :request_permissions,  :class => "Ib::Db::Persons::Permission", :key => :request_node_id
        one_to_many :response_permissions, :class => "Ib::Db::Persons::Permission", :key => :response_node_id
        # @todo
        def validate
          validates_presence [:name,:readers_nr,:devices_nr]
          validates_integer [:readers_nr,:devices_nr], :allow_nil => true
          validates_max_length(readers_nr, [:readers])
          validates_max_length(devices_nr, [:devices])
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
            {:css => "normal",:name  => "sid",:label => I18n.t('hw_node.sid'),:value => sid},
            {:css => "datetime",:name  => "sid_at",:label => I18n.t('hw_node.sid_at'),:value => sid_at},
            {:css => "normal",:name  => "name",:label => I18n.t('hw_node.name'),:value => name},
            {:css => "integer",:name  => "readers_nr",:label => I18n.t('hw_node.readers_nr'),:value => readers_nr},
            {:css => "integer",:name  => "devices_nr",:label => I18n.t('hw_node.devices_nr'),:value => devices_nr},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
        protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Hw::Node id=#{id}",
                            :error => I18n.t("hw_node.delete_message", :readers => readers.length, :devices => devices.length, :request_permissions => request_permissions.length, :response_permissions => response_permissions.length))
        end
      end
    end
  end
end

