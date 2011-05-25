#encoding: utf-8

module Ib
  module Utils
    def options
      Ib.options
    end
    def options=(obj)
      Ib.options = obj
    end
    def ibs
      Ib.ibs
    end
    def ibs=(obj)
      Ib.ibs = obj
    end
    def base_dir
      Ib.base_dir
    end
    def log_path
      Ib.log_path
    end
    def pid_dir
      Ib.pid_dir
    end
    def logger
      Ib.logger
    end
  end
end