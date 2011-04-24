#encoding: utf-8

module Ib
  module Db
    module Log
      class Access
        set_dataset :log_accesses
        plugin :timestamps
      end
    end
  end
end