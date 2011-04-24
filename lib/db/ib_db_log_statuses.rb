#encoding: utf-8

module Ib
  module Db
    module Log
      class Status
        set_dataset :log_statuses
        plugin :timestamps
      end
    end
  end
end