#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Owner model
      # ##Migration 0006_create_table_persons_owners.rb
      #     def up
      #       create_table(:persons_owners) do
      #         primary_key :id
      #         column      :first_name,    String,     :size => 20
      #         column      :last_name,     String,     :size => 20
      #         column      :created_at,    DateTime
      #         column      :updated_at,    DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:persons_owners)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations
      #   *many_to_one*  -> key    {Ib::Db::Hw::Key}<br />
      #   *one_to_one*   -> admin  {Ib::Db::Persons::Admin}<br />
      #   *many_to_many* -> groups {Ib::Db::Persons::Group} *Attention!* *:join_table => :prs_groups_owners*
      # ##Validations
      #   TODO document validations
      # @example Owners keyId and login_name
      #   o = Owner.first
      #   o.key.keyId                   #=> String key's keyId
      #   o.admin.login_name if o.admin #=> String login_name if owner is admin
      # @example Belongs to groups
      #   o = Owner.first
      #   o.groups        #=> Array of {Ib:Db::Persons::Group} objects
      class Owner < Sequel::Model
        set_dataset :prs_owners
        plugin :timestamps
        plugin :validation_helpers

        one_to_many  :ib_keys, :class => "Ib::Db::Hw::Key", :key => :owner_id
        one_to_one   :admin
        many_to_many :groups, :join_table => :prs_groups_owners

        class << self
          # @todo document this method
          def new_record_defaults
            [
              {:css => "normal",:name => "first_name",:label => I18n.t('persons_owner.first_name'),:value => "FirstName"},
              {:css => "normal",:name => "last_name",:label => I18n.t('persons_owner.last_name'),:value => "LastName"}
            ]
          end
          # @todo document this method
          def auto_search(e)
            e = e.include?('group')
            owners = [:id => "0",:name => "Remove Owner",:label => "<span class='warning'>Remove selected</span>"]
            owners = [] if e
            order(:last_name.asc).all do |o|
              label = "#{o.full_name} #{o.ib_keys.empty? ? ' | has no Key' : ''}"
              label = "#{o.full_name} #{o.groups.empty? ? ' | has no Group' : ''}" if e
              owners << {:id => o.id,:name => o.full_name,:label => label}
            end
            {:identifier => "id",:items => owners}
          end
        end

        # @todo
        def validate
          validates_presence [:first_name, :last_name]
          validates_max_length 20, [:first_name, :last_name],  :allow_nil => true
        end
        # Send a warning
        #   If the owner is deleted his/her associated admin account is deleted,
        #   ofcourse if he/she has one :) .
        #   Out of record, is inadequate to modify the owners account changing
        #   the name. All associations are made on the "id" column and the "new user"
        #   inherits the "ids" history, permissions etc.
        # @return [Log::Error]
        def before_destroy
          delete_message
          super
        end
        # @return [String] Owners full name
        #   Full name (Last name First name)
        def full_name
          retval = last_name + ' ' + first_name
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
            {:css => "normal",:name  => "first_name",:label => I18n.t('persons_owner.first_name'),:value => first_name},
            {:css => "normal",:name  => "last_name",:label => I18n.t('persons_owner.last_name'),:value => last_name},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
        protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Persons::Owner id=#{id}",
                            :error => I18n.t('crud.log.delete'))
        end
      end
    end
  end
end

