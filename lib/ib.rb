#encoding: utf-8
require 'bundler/setup'
require 'ostruct'
require 'logger'
Dir['config','lib/*'].each do |dir|
  dir = File.join(File.expand_path('..',File.dirname(__FILE__)),dir)
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end
require 'utils'
# @todo documentation
module Ib

  VERSION = "0.1.0"

  @@options = OpenStruct.new
  @@ibs = nil

  class << self
    # @todo
    def options
      @@options
    end
    # @todo
    def options=(v)
      @@options = v
    end
    #todo
    def ibs
      @@ibs
    end
    #todo
    def ibs=(v)
      @@ibs = v
    end
    # @todo
    def logger
      return @@logger if defined?(@@logger)
      FileUtils.mkdir_p(File.dirname(log_path))
      @@logger = Logger.new(log_path)
      @@logger.level = Logger::Info if options.debug == false
      @@logger
    rescue
       @@logger = Logger.new(STDOUT)
    end
    # @todo
    def app_root
      options.app_root || File.join(File.expand_path('..',File.dirname(__FILE__)))
    end
    # @todo
    def log_path
      options.log_path || File.join(app_root,'log', 'serial.log')
    end
    # @todo
    def pid_dir
      options.pid_dir || File.join(app_root,'tmp','pids')
    end
  end

  autoload :Db,         'db'
  autoload :Serial,     'serial'

end