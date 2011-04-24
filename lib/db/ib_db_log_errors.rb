#encoding: utf-8

module Ib
  module Db
    module Log
      class Error
        set_dataset :log_errors
        plugin :timestamps
      end
    end
  end
end