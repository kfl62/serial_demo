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
      end
    end
  end
end
