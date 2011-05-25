#encoding: utf-8
module Ib
  module Serial
    class Daemon
      include Utils

      class << self
        def run
          self.new
        end
      end

      def initialize
        options.device = '/dev/ttyS0'
        options.baud_rate = 115200
        options.debug = false
        load_from_file
        parse_options
        if options.kill
          kill_pid
        end
        unless options.daemonize
          start
        else
          daemonize
        end
      end
      def start
        puts "\nConnected to: #{options.device}\n"
        trap("INT"){
          stop
          exit
        }
        trap("TERM"){
          stop
          exit
        }
        self.ibs = Server.new(options.device, options.baud_rate)
        msg = ibs.gets
        if msg.length == 22
          ibs.handle(msg)
        end
      end
      def stop
        puts "\nClosed connection to: #{options.device} !"
        ibs.close
      end
      def load_from_file
        config_file = File.join(app_root,'config','simple_conf.yaml')
        if File.exists?(config_file)
          opt = YAML.load_file(config_file)["Serial"]
          opt.each_pair do |k,v|
            options.send k + "=",v
          end
        end
      end
      def parse_options
        if ARGV.any?
          require 'optparse'
          OptionParser.new { |opt|
            opt.summary_width = 25
            opt.banner = "Ibutton server (#{VERSION})\n\n"\
                         "Usage: ibutton [-d] [-p port] [-b baud] [-l loglevel] [-k]\n"\
                         "       ibutton --help\n"\
                         "       ibutton --version"
            opt.separator ""; opt.separator "Configuration:"
            opt.on("-d", "--daemon", "Daemonize mode"){|v| options.daemonize = v}
            opt.on("-p", "--port Port", String,
                   "File name of the device.You may set in config file!",
                   "(default: #{options.device})"){|v| options.device = v}
            opt.on("-b", "--baud Baudrate", Integer,
                   "Integer from 50 to 256000.You may set in config file!",
                   "(default: #{options.baud_rate})"){|v| options.baud_rate = v}
            opt.on("-l", "--debug Debug", TrueClass,
                   "Set to true for verbose logging",
                   "(default: #{options.debug})"){|v| options.debug = v}
            opt.on("-k", "--kill", "Kill daemon on port #{options.device}."){|v| options.kill = v}
            opt.on_tail("-h", "--help", "Display this usage information."){puts "#{opt}\n";exit}
            opt.on_tail("-v", "--version", "Display version"){puts "Ibutton #{VERSION}";exit}
          }.parse!
          options
        end
      end
      def kill_pid
        f = File.join(pid_dir,"ibutton.pid")
        if File.file?(f)
          begin
          pid = IO.read(f).chomp.to_i
          Process.kill(15, pid)
          puts "Daemon stopped!"
          FileUtils.rm f
          rescue => e
            puts "Failed to kill! Pid=#{pid}: #{e}"
          end
        else
          puts "Pid file not found. Is the daemon started?"
        end
        exit
      end
      def store_pid(pid)
        FileUtils.mkdir_p(pid_dir)
        File.open(File.join(pid_dir,"ibutton.pid"), 'w'){|f| f << pid}
      end
      def daemonize
        fork do
          Process.setsid
          exit if fork
          store_pid(Process.pid)
          STDIN.reopen '/dev/null'
          STDOUT.reopen '/dev/null', "a"
          STDERR.reopen STDOUT
          start
        end
      end
    end
  end
end
