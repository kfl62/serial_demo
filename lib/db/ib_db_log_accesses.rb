#encoding: utf-8

module Ib
  module Db
    module Log
      # #IButton Database Log-Access model
      # ##Migration 0011_create_table_log_accesses.rb
      #      def up
      #        create_table('log_accesses') do
      #          primary_key :id
      #          column      :created_at, DateTime
      #          column      :owner_id,   Fixnum
      #          column      :owner,      String,     :size => 40
      #          column      :node,       String,     :size => 20
      #          column      :reader,     String,     :size => 20
      #          column      :device,     String,     :size => 20
      #          column      :task,       String,     :size => 20
      #          column      :status,     TrueClass,               :default => true
      #        end
      #      end
      #      def down
      #        drop_table(:log_accesses)
      #      end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})
      class Access < Sequel::Model
        set_dataset :log_accesses
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
