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
      #          column      :node_req,   String,     :size => 20
      #          column      :reader,     String,     :size => 20
      #          column      :node_res,   String,     :size => 20
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
            {:css => "datetime",:name  => "created_at",:label => I18n.t('log_access.created_at'),:value => created_at},
            {:css => "integer",:name  => "owner_id",:label => I18n.t('log_access.owner_id'),:value => owner_id},
            {:css => "normal",:name  => "owner",:label => I18n.t('log_access.owner'),:value => owner},
            {:css => "normal",:name  => "node_req",:label => I18n.t('log_access.node_req'),:value => node_req},
            {:css => "normal",:name  => "reader",:label => I18n.t('log_access.reader'),:value => reader},
            {:css => "normal",:name  => "node_res",:label => I18n.t('log_access.node_res'),:value => node_res},
            {:css => "normal",:name  => "device",:label => I18n.t('log_access.device'),:value => device},
            {:css => "normal",:name  => "task",:label => I18n.t('log_access.task'),:value => task},
            {:css => "normal",:name  => "status",:label => I18n.t('log_access.status'),:value => status}
          ]
        end
      end
    end
  end
end
