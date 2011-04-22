#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Node model
      # @todo document this class
      class Node < Sequel::Model
        set_dataset :hw_nodes
        plugin :timestamps

        one_to_many :readers
        one_to_many :devices
      end
    end
  end
end

