#encoding: utf-8
module Ib
  # #Ib::Mixins module
  # ##Description:
  # ##Scope:
  # @todo document this module
  module Mixins
    # @todo
    def opt
      Ib.opt
    end
    # @todo
    def opt=(v)
      Ib.opt = v
    end
    # @todo
    def ibs
      Ib.ibs
    end
    # @todo
    def ibs=(v)
      Ib.ibs = v
    end
    # @todo
    def app_root
      Ib.app_root
    end
    # @todo
    def sinatra_views
      Ib.sinatra_views
    end
    # @todo
    def log_path
      Ib.log_path
    end
    # @todo
    def pid_dir
      Ib.pid_dir
    end
    # @todo
    def logger
      Ib.logger
    end
  end
end
