#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Key model
      # ##Migration 0001_create_table_hw_keys.rb
      #     def up
      #       create_table(:hw_keys) do
      #         primary_key :id
      #         column      :keyId,       String,   :size => 12
      #         column      :created_at,  DateTime
      #         column      :updated_at,  DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:hw_keys)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugins timestamps})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations
      # *one_to_one* -> owner {Ib::Db::Persons::Owner}
      # ##Validations
      #   Validate exact length of keyId, must be varchar(12)
      # @example Owners first name
      #   k = Key.first
      #   k.owner.first_name #=> first name of the keys owner
      class Key < Sequel::Model
        set_dataset :hw_keys
        plugin :timestamps
        plugin :validation_helpers

        one_to_one :owner, :class => "Ib::Db::Persons::Owner"
        # Exact length of keyId is 12
        def validate
          validates_exact_length 12, :keyId
        end
        # Send a warning
        #   If the key is deleted, the former owners key_id is set to 1
        #   which is a fake key's id, with keyId = 123456789ABC
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
            {:css => "normal",:name  => "keyId",:label => I18n.t('hw_key.keyId'),:value => keyId},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
        protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Hw::Key id=#{id}",
                            :error => I18n.t('hw_key.delete_message',:data => owner.full_name))
        end
      end
    end
  end
end

