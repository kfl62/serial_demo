#encoding: utf-8

module Ib
  module Db
    module Log
      # #IButton Database Log-Error model
      # ##Migration 0012_create_table_log_errors.rb
      #      def up
      #        create_table('log_errors') do
      #          primary_key :id
      #          column      :created_at, DateTime
      #          column      :node_id,    Fixnum
      #          column      :node,       String,     :size => 20
      #          column      :error,      String,     :size => 20
      #        end
      #      end
      #      def down
      #        drop_table(:log_errors)
      #      end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})
      class Error < Sequel::Model
        set_dataset :log_errors
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
