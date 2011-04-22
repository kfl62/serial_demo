#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Key model
      # @todo document this class
      class Key < Sequel::Model
        set_dataset :hw_keys
        plugin :timestamps

        one_to_one :owner, :class => "Ib::Db::Persons::Owner"
      end
    end
  end
end

