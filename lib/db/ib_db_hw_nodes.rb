#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Node model
      # ##Migration 002_create_table_hw_nodes.rb
      #     def up
      #       create_table(:hw_nodes) do
      #         primary_key :id
      #         column      :sid,           String,     :size => 4, :default => "2046"
      #         column      :sid_at,        DateTime
      #         column      :name,          String
      #         column      :readers_nr,    Fixnum,     :size => 2
      #         column      :devices_nr,    Fixnum,     :size => 2
      #         column      :answer_status, TrueClass,              :default => false
      #         column      :created_at,    DateTime
      #         column      :updated_at,    DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:hw_nodes)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestams})
      # ##Associations
      #   *one_to_many* -> {Ib::Db::Hw::Reader}<br />
      #   *one_to_many* -> {Ib::Db::Hw::Device}
      # @example Connected readers/devices
      #   n = Node.first
      #   n.readers         #=> Array of connected readers
      #   n.devices.length  #=> Integer the count of connected devices
      class Node < Sequel::Model
        set_dataset :hw_nodes
        plugin :timestamps

        one_to_many :readers
        one_to_many :devices
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
            {:css => "normal",:name  => "answer_status",:label => I18n.t('hw_node.answer_status'),:value => answer_status},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
      end
    end
  end
end

