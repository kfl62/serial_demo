#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Reader model
      # ##Migration 003_create_table_hw_readers.rb
      #     def up
      #       create_table(:hw_readers) do
      #         primary_key :id
      #         foreign_key :node_id,       :hw_nodes
      #         column      :name,          String
      #         column      :order,         String,     :size => 2
      #         column      :created_at,    DateTime
      #         column      :updated_at,    DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:hw_readers)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestams})
      # ##Associations
      #   *many_to_one* -> {Ib::Db::Hw::Node}
      # @example Connected to node?
      #   r = Reader.first
      #   r.node.sid         #=> Integer connected node's sid
      class Reader < Sequel::Model
        set_dataset :hw_readers
        plugin :timestamps

        many_to_one :node
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
            {:css => "integer",:name => "node_id",:label => I18n.t('hw_reader.node_id'),:value => node_id},
            {:css => "normal",:name  => "name",:label => I18n.t('hw_reader.name'),:value => name},
            {:css => "normal",:name  => "order",:label => I18n.t('hw_reader.order'),:value => order},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
      end
    end
  end
end

