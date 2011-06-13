#encoding: utf-8
require 'bundler/setup'
require 'ostruct'
require 'logger'
require 'drb'
require 'i18n'
#require 'compass'
Dir['config','lib/*'].each do |dir|
  dir = File.join(File.expand_path('..',File.dirname(__FILE__)),dir)
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end
require 'mixins'
# @todo documentation
module Ib
  # @todo
  VERSION = "0.1.0"

  @@opt = OpenStruct.new
  @@ibs = nil

  class << self
    # @todo
    def opt
      @@opt
    end
    # @todo
    def opt=(v)
      @@opt = v
    end
    # @todo
    def ibs
      @@ibs
    end
    # @todo
    def ibs=(v)
      @@ibs = v
    end
    # @todo
    def logger
      return @@logger if defined?(@@logger)
      FileUtils.mkdir_p(File.dirname(log_path))
      log_where = (opt.daemonize || opt.kill) ? log_path : STDOUT
      @@logger = Logger.new(log_where)
      @@logger.level = opt.debug ? Logger::DEBUG : Logger::INFO
      @@logger.instance_eval do
        def format_message(severity, datetime, progname, msg)
          "[%s %s] - %s\n" % [ severity.ljust(5), datetime.strftime("%Y-%m-%d %H:%M:%S"), msg ]
        end
      end
      @@logger
    rescue
       @@logger = Logger.new(STDOUT)
    end
    # @todo
    def app_root
      opt.app_root || File.join(File.expand_path('..',File.dirname(__FILE__)))
    end
    # @todo
    def sinatra_views
      opt.sinatra_views || File.join(app_root,'lib','ib','web','views')
    end
    # @todo
    def log_path
      opt.log_path || File.join(app_root,'log', 'serial.log')
    end
    # @todo
    def pid_dir
      opt.pid_dir || File.join(app_root,'tmp','pids')
    end
  end

  I18n.load_path += Dir.glob(File.join(app_root,'lib', 'i18n', '*.yml'))
  I18n.default_locale = :en

  autoload :Db,         'db'
  autoload :Serial,     'serial'
  autoload :Web,        'web'

end