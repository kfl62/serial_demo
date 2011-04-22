#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Owners model
      # @todo document this class
      class Owner < Sequel::Model
        set_dataset :prs_owners
        plugin :timestamps

        many_to_one :key, :class => "Ib::Db::Hw::Key"
        one_to_one  :admin
      end
    end
  end
end

