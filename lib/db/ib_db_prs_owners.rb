#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Owners model
      # ##Migration 005_create_table_persons_owners.rb
      #     def up
      #       create_table(:persons_owners) do
      #         primary_key :id
      #         foreign_key :key_id,        :hw_keys
      #         column      :first_name,    String
      #         column      :last_name,     String
      #         column      :created_at,    DateTime
      #         column      :updated_at,    DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:persons_owners)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestams})
      # ##Associations
      #   *many_to_one* -> {Ib::Db::Hw::Key}<br />
      #   *one_to_one*  -> {Ib::Db::Persons::Admin}
      # @example Owners keyId and login_name
      #   o = Owner.first
      #   o.key.keyId                   #=> String key's keyId
      #   o.admin.login_name if o.admin #=> String login_name if owner is admin
      class Owner < Sequel::Model
        set_dataset :prs_owners
        plugin :timestamps

        many_to_one :key, :class => "Ib::Db::Hw::Key"
        one_to_one  :admin
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
            {:css => "integer",:name => "key_id",:label => I18n.t('persons_owner.node_id'),:value => key_id},
            {:css => "normal",:name  => "name",:label => I18n.t('persons_owner.first_name'),:value => first_name},
            {:css => "normal",:name  => "order",:label => I18n.t('persons_owner.last_name'),:value => last_name},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
      end
    end
  end
end

