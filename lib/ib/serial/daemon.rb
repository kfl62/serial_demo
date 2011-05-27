#encoding: utf-8
module Ib
  module Serial
    class Daemon
      include Mixins
      # Just a convenience method for Ib::Serial::Daemon.new
      class << self
        # Initialize and run(stop) server on serial port
        def run
          self.new
        end
      end
      # @todo
      def initialize
        opt.device = '/dev/ttyS0'
        opt.baud_rate = 115200
        opt.debug = false
        load_options_from_file
        parse_opt
        if opt.kill
          kill_pid
        end
        if opt.daemonize
          daemonize
        else
          start
        end
      end
      # Start watching communication on serial port
      # @todo more documentation :)
      def start
        trap("INT"){
          stop
          exit
        }
        trap("TERM"){
          stop
          exit
        }
        begin
          self.ibs = Server.new(opt.device, opt.baud_rate)
        rescue Errno::ENOENT, Errno::EACCES => e
          puts "Port (#{opt.device}) not found or wrong permissions! Exiting..."
          puts "\n\nDebug message:\n#{e.message}\n#{e.backtrace.join("\n")}" if opt.debug
          exit 1
        else
          logger.info "Connected to: #{opt.device}"
        end
        while true do
          begin
            msg = ibs.gets
            raise SerialError, "Incorrect data length: #{msg.length}" if msg.length != 22
          rescue SerialError => e
            logger.error e.message
          end
          logger.debug "Msg ASCII: #{@msg.chop}\\n"
          ibs.handle(msg)
        end
      end
      # @todo
      def stop
        logger.info "Disconnected from: #{opt.device}"
        ibs.close
      end
      # @todo
      def load_from_file
        config_file = File.join(app_root,'config','simple_conf.yaml')
        if File.exists?(config_file)
          opts = YAML.load_file(config_file)["Serial"]
          opts.each_pair do |k,v|
            opt.send k + "=",v
          end
        end
      end
      # @todo
      def parse_opt
        if ARGV.any?
          require 'optparse'
          opts = OptionParser.new { |opts|
            opts.summary_width = 25
            opts.banner = "Ibutton server (#{VERSION})\n\n"\
                         "Usage: ibutton [-d] [-k] [--debug] [-p port] [-b baud]\n"\
                         "       ibutton --help\n"\
                         "       ibutton --version"
            opts.separator ""; opts.separator "Control opt:"
            opts.on("-d", "--daemon", "Run daemonized in the background"){|v| opt.daemonize = v}
            opts.on("-k", "--kill", "Kill daemon on port #{opt.device}."){|v| opt.kill = v}
            opts.on("--debug","Enable debug level logging"){|v| opt.debug = true}
            opts.separator ""; opts.separator "Serial port opt:"
            opts.on("-p", "--port Port", String,
                   "File name of the device.You may set in config file!",
                   "(default: #{opt.device})"){|v| opt.device = v}
            opts.on("-b", "--baud Baudrate", Integer,
                   "Integer from 50 to 256000.You may set in config file!",
                   "(default: #{opt.baud_rate})"){|v| opt.baud_rate = v}
            opts.separator ""; opts.separator "Other opt:"
            opts.on_tail("-h", "--help", "Display this usage information."){puts "#{opt}\n";exit}
            opts.on_tail("-v", "--version", "Display version"){puts "Ibutton #{VERSION}";exit}
          }
          begin opts.parse! ARGV
          rescue  OptionParser::InvalidOption => e
            puts e
            puts opt
            exit 1
          end
          opt
        end
      end
      # @todo
      def kill_pid
        f = File.join(pid_dir,"ibutton.pid")
        if File.file?(f)
          begin
            pid = IO.read(f).chomp.to_i
            Process.kill(15, pid)
            FileUtils.rm f
            puts "Daemon stopped!" if opt.kill
            logger.info "Serial daemon stopped"
          rescue => e
            puts "Failed to kill! Pid=#{pid}: #{e}"
          end
        else
          puts "Pid file not found. Is the daemon started?"
        end
        exit
      end
      # @todo
      def store_pid(pid)
        FileUtils.mkdir_p(pid_dir)
        File.open(File.join(pid_dir,"ibutton.pid"), 'w'){|f| f << pid}
      end
      # @todo
      def daemonize
        fork do
          Process.setsid
          exit if fork
          if File.file?(File.join(pid_dir,"ibutton.pid"))
            puts "Pid file #{File.expand_path(File.join(pid_dir,'ibutton.pid'))} already exists.  Not starting."
            exit 1
          end
          store_pid(Process.pid)
          logger.info "Serial daemon started"
          puts "Daemon started!"
          STDIN.reopen '/dev/null'
          STDOUT.reopen '/dev/null', "a"
          STDERR.reopen STDOUT
          start
        end
      end
    end
  end
end