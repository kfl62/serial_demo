#encoding: utf-8

module Ib
  module Serial
    module Utils
      def options
        Ib::Serial.options
      end
      def base_dir
        Ib::Serial.base_dir
      end
      def log_path
        Ib::Serial.log_path
      end
      def pid_dir
        Ib::Serial.pid_dir
      end
      def logger
        Ib::Serial.logger
      end
    end
  end
end