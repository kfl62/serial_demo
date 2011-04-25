#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Group model
      # ##Migration 0008_create_table_persons_groups.rb
      #     def up
      #       create_table('prs_groups') do
      #         primary_key :id
      #         column      :name,          String,     :size => 20
      #         column      :created_at,    DateTime
      #         column      :updated_at,    DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:prs_groups)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestams})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations
      #   *many_to_many* -> owners {Ib::Db::Persons::Owner} *Attention!* *:join_table => :prs_groups_owners*
      # ##Validations
      #   TODO document validations
      # @example Group members
      #   g = Group.first
      #   g.owners        #=> Array of {Ib:Db::Persons::Owner} objects
      class Group < Sequel::Model
        set_dataset :prs_groups
        plugin :timestamps
        plugin :validation_helpers

        many_to_many :owners,      :join_table => :prs_groups_owners
        one_to_many  :permissions
        # @todo
        def validate
          validates_presence :name
          validates_max_length 20, :name,  :allow_nil => true
        end
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
            {:css => "normal",:name  => "name",:label => I18n.t('persons_owner.first_name'),:value => first_name},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
        protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Persons::Group id=#{id}",
                            :error => I18n.t('persons_group.delete_message', :group => name, :permissions => permissions))
        end
      end
    end
  end
end
