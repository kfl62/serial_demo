#encoding: utf-8

module Ib
  module Db
    module Hw
      #IButton Database Hardware-Device model
      # @todo document this class
      class Device < Sequel::Model
        set_dataset :hw_devices
        plugin :timestamps

        many_to_one :node
      end
    end
  end
end

