#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Admins model
      # @todo document this class
      class Admin < Sequel::Model
        set_dataset :prs_admins
        plugin :timestamps

        many_to_one :owner

        class << self
          def authenticate (login_name, pass)
            current_user = first(:login_name => login_name)
            return nil if current_user.nil?
            return current_user if encrypt(pass, current_user.salt) == current_user.hashed_password
            nil
          end
          def encrypt(pass, salt)
            Digest::SHA1.hexdigest(pass+salt)
          end
        end
        def password=(pass)
          @password = pass
          self.salt = random_string(10) if !self.salt
          self.hashed_password = Admin.encrypt(@password, self.salt)
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
      end
    end
  end
end

