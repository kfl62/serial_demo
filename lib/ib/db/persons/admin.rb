#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Admin model
      # ##Migration 0007_create_table_persons_admins.rb
      #     def up
      #       create_table(:persons_admins) do
      #         primary_key :id
      #         foreign_key :owner_id,        :prs_owners, :on_delete => :cascade, :on_update => :cascade
      #         column      :login_name,      String,      :size => 20
      #         column      :email,           String,      :size => 20
      #         column      :salt,            String
      #         column      :hashed_password, String
      #         column      :created_at,      DateTime
      #         column      :updated_at,      DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:persons_admins)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations
      #   *many_to_one* -> owner {Ib::Db::Persons::Owner}
      # ##Validations
      #   TODO document validations
      # @example Owners keyId
      #   o = Owner.first
      #   o.key.keyId                   #=> String key's keyId
      class Admin < Sequel::Model
        set_dataset :prs_admins
        plugin :timestamps
        plugin :validation_helpers

        many_to_one :owner
        # @todo
        def validate
          validates_presence [:login_name, :email]
          validates_max_length 20, [:login_name, :email],  :allow_nil => true
        end
        # @return [Log::Error]
        def before_destroy
          delete_message
          super
        end

        class << self
          # @todo
          def authenticate (login_name, pass)
            current_user = first(:login_name => login_name)
            return nil if current_user.nil?
            return current_user if encrypt(pass, current_user.salt) == current_user.hashed_password
            nil
          end
          # @todo
          def encrypt(pass, salt)
            Digest::SHA1.hexdigest(pass+salt)
          end
        end

        # Change/Add password for admin *CLI only*
        def password=(pass)
          @password = pass
          self.salt = random_string(10) if !self.salt
          self.hashed_password = Admin.encrypt(@password, self.salt)
        end
        # @todo
        def validate
          validates_presence [:login_name, :email]
          validates_max_length 20, [:login_name, :email],  :allow_nil => true
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
        # @todo
        def table_data
          [
            {:css => "integer",:name => "id",:label => I18n.t('mdl.id'),:value => id},
            {:css => "normal",:name => "owner_id",:label => I18n.t('persons_admin.owner_id'),:value => owner.full_name},
            {:css => "normal",:name  => "login_name",:label => I18n.t('persons_admin.login_name'),:value => login_name},
            {:css => "normal",:name  => "email",:label => I18n.t('persons_admin.email'),:value => email},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
        protected
        # Generate `#user.salt` for new `#user`
        # @return [String] random string for `#user.salt`
        def random_string(len)
          chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
          newsalt = ""
          1.upto(len) { |i| newsalt << chars[rand(chars.size-1)] }
          return newsalt
        end
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Persons::Admin id=#{id}",
                            :error => I18n.t('crud.log.delete'))
        end
      end
    end
  end
end

