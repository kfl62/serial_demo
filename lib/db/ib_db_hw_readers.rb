#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Reader model
      # @todo document this class
      class Reader < Sequel::Model
        set_dataset :hw_readers
        plugin :timestamps

        many_to_one :node
      end
    end
  end
end

