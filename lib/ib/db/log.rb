#encoding: utf-8

module Ib
  module Db
    # Just for namespace and docs
    module Log
      autoload :Access,   'db/log/access'
      autoload :Error,    'db/log/error'
      autoload :Status,   'db/log/status'
    end
  end
end