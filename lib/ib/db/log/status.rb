#encoding: utf-8

module Ib
  module Db
    module Log
      # #IButton Database Log-Error model
      # ##Migration 0013_create_table_log_statuses.rb
      #      def up
      #        create_table('log_statuses') do
      #          primary_key :id
      #          column      :created_at, DateTime
      #          column      :node_id,    Fixnum
      #          column      :node,       String,     :size => 20
      #          column      :updated_at, DateTime
      #        end
      #      end
      #      def down
      #        drop_table(:log_statuses)
      #      end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})
      class Status < Sequel::Model
        set_dataset :log_statuses
        plugin :timestamps

        def is_alive
          Time.now.to_i - updated_at.to_i > 60 ? "DEAD" : "ALIVE"
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
            {:css => "datetime",:name  => "created_at",:label => I18n.t('log_status.created_at'),:value => created_at},
            {:css => "integer",:name  => "node_id",:label => I18n.t('log_status.node_id'),:value => node_id},
            {:css => "normal",:name  => "node",:label => I18n.t('log_status.node'),:value => node},
            {:css => "ce bo",:name  => "is_alive",:label => I18n.t('log_status.is_alive'),:value => is_alive},
            {:css => "time",:name  => "updated_at",:label => I18n.t('log_status.updated_at'),:value => updated_at}
          ]
        end
      end
    end
  end
end
