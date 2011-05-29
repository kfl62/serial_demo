#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Node model
      # ##Migration 0002_create_table_hw_nodes.rb
      #     def up
      #       create_table(:hw_nodes) do
      #         primary_key :id
      #         column      :sid,           Fixnum,                 :default => 2046
      #         column      :sid_at,        DateTime
      #         column      :name,          String,     :size => 20,:default => "New node"
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

        class << self
          # @todo document this method
          def new_record_defaults
            [
              {:css => "hidden",:name => "sid",:label => I18n.t('hw_node.sid'),:value => 2046},
              {:css => "hidden",:name  => "readers_nr",:label => I18n.t('hw_node.readers_nr'),:value => 1},
              {:css => "hidden",:name  => "devices_nr",:label => I18n.t('hw_node.devices_nr'),:value => 1},
              {:css => "normal",:name  => "name",:label => I18n.t('hw_node.name'),:value => "New node"}
            ]
          end
          # @todo document this method
          def auto_search(e)
            d = e.include?("device")
            p = e.include?("permission")
            nodes = [:id => "0",:name => "Remove Node",:label => "<span class='warning'>Remove selected</span>"]
            nodes = [] if p
            all do |n|
              label = "#{n.name} #{n.readers.empty? ? ' | has no Readers' : ''}"
              label = "#{n.name} #{n.devices.empty? ? ' | has no Devices' : ''}" if d
              label = "#{n.name}" if p
              nodes << {:id => n.id,:name => n.name,:label => label}
            end
            {:identifier => "id",:items => nodes}
          end
        end

       # @todo
        def validate
          validates_presence [:sid,:readers_nr,:devices_nr]
          validates_integer [:sid,:readers_nr,:devices_nr], :allow_nil => true
          validates_max_length(readers_nr, [:readers])
          validates_max_length(devices_nr, [:devices])
        end
        # @todo
        # @return [Log::Error]
        def before_destroy
          delete_message
          super
        end
        # @todo
        def max_con_readers
          readers_nr.to_s + '/' + readers.length.to_s
        end
        # @todo
        def max_con_devices
          devices_nr.to_s + '/' + devices.length.to_s
        end
        # @todo
        def by_reader_order(order)
          readers_dataset.filter(:order => order).first
        end
        # @todo
        def by_device_order(order)
          devices_dataset.filter(:order => order).first
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
            {:css => "integer",:name  => "sid",:label => I18n.t('hw_node.sid'),:value => sid},
            {:css => "datetime",:name  => "sid_at",:label => I18n.t('hw_node.sid_at'),:value => sid_at},
            {:css => "normal",:name  => "name",:label => I18n.t('hw_node.name'),:value => name},
            {:css => "integer",:name  => "readers_nr",:label => I18n.t('hw_node.readers_nr'),:value => max_con_readers},
            {:css => "integer",:name  => "devices_nr",:label => I18n.t('hw_node.devices_nr'),:value => max_con_devices},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
        protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Hw::Node id=#{id}",
                            :error => I18n.t('crud.log.delete'))
        end
      end
    end
  end
end

