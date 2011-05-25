#encoding: utf-8

module Ib
  module Utils
    def options
      Ib.options
    end
    def options=(v)
      Ib.options = v
    end
    def ibs
      Ib.ibs
    end
    def ibs=(v)
      Ib.ibs = v
    end
    def app_root
      Ib.app_root
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