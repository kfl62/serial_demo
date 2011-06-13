#encoding: utf-8
module Ib
  module Serial
    # @todo
    class Daemon
      include Mixins
      class << self
        # Initialize and run(stop) server on serial port
        def run
          self.new
        end
      end
      # @todo
      def initialize
        opt.device    = '/dev/ttyS0'
        opt.baud_rate = 115200
        opt.debug     = false
        opt.mail      = false
        opt.start     = Time.now
        load_options_from_file
        parse_opt_cli
        if opt.mail
          parse_opt_mail
        end
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
          DRb.start_service "drbunix://#{pid_dir}/ibutton_serial.sock", self.ibs
          fork do
            Process.setsid
            exit if fork
            STDIN.reopen '/dev/null'
            STDOUT.reopen '/dev/null', "a"
            STDERR.reopen STDOUT
            DRb.thread.join
          end
        rescue Errno::ENOENT, Errno::EACCES => e
          puts "Port (#{opt.device}) not found or wrong permissions! Exiting..."
          puts "\n\nDebug message:\n#{e.message}\n#{e.backtrace.join("\n")}" if opt.debug
          exit 1
        else
          logger.info("Connected to: #{opt.device}")
        end
        while true do
          begin
            msg = ibs.gets
            raise SerialError, "Incorrect data length: #{msg.length}" if msg.length != 22
          rescue SerialError => e
            logger.debug("Msg ASCII: #{msg.chop}\\n")
            logger.error(e.message)
            logger.error("Message dropped!")
          else
            logger.debug("Msg ASCII: #{msg.chop}\\n")
            ibs.srv_handle_incoming(msg)
          end
        end
      end
      # @todo
      def stop
        logger.info("Disconnected from: #{opt.device}")
        DRb.stop_service
        FileUtils.rm_f File.join(pid_dir,"ibutton_serial.sock")
        ibs.close
      end
      # @todo
      def load_options_from_file
        config_file = File.join(app_root,'config','simple_conf.yaml')
        if File.exists?(config_file)
          opts = YAML.load_file(config_file)["Serial"]
          opts.each_pair do |k,v|
            opt.send k + "=",v
          end
        end
        opt
      end
      # @todo
      def parse_opt_cli
        if ARGV.any?
          require 'optparse'
          opts = OptionParser.new { |opts|
            opts.summary_width = 25
            opts.banner = "Ibutton server (#{VERSION})\n\n"\
                         "Usage: ibutton [-d] [-k] [--debug] [--mail]\n"\
                         "               [-p port] [-b baud]\n"\
                         "       ibutton --help\n"\
                         "       ibutton --version"
            opts.separator ""; opts.separator "Control options:"
            opts.on("-d", "--daemon", "Run daemonized in the background"){|v| opt.daemonize = v}
            opts.on("-k", "--kill", "Kill daemon on port #{opt.device}."){|v| opt.kill = v}
            opts.on("--debug","Enable debug level logging"){|v| opt.debug = true}
            opts.on("--mail","Enable mailer"){|v| opt.mail = true}
            opts.separator ""; opts.separator "Serial port options:"
            opts.on("-p", "--port Port", String,
                   "File name of the device.You may set in config file!",
                   "(default: #{opt.device})"){|v| opt.device = v}
            opts.on("-b", "--baud Baudrate", Integer,
                   "Integer from 50 to 256000.You may set in config file!",
                   "(default: #{opt.baud_rate})"){|v| opt.baud_rate = v}
            opts.separator ""; opts.separator "Other options:"
            opts.on_tail("-h", "--help", "Display this usage information."){puts "#{opts}\n";exit}
            opts.on_tail("-v", "--version", "Display version"){puts "Ibutton #{VERSION}";exit}
          }
          begin opts.parse! ARGV
          rescue  OptionParser::InvalidOption => e
            puts e
            puts opts
            exit 1
          end
          opt
        end
      end
      # @todo
      def parse_opt_mail
        require 'pony'
        config_file = File.join(app_root,'config','simple_conf.yaml')
        if File.exists?(config_file)
          opts = YAML.load_file(config_file)["Mail"]
        end
        Pony.options = opts
      end
      # @todo
      def kill_pid
        f = File.join(pid_dir,"ibutton.pid")
        s = File.join(pid_dir,"ibutton.status")
        if File.exists?(f)
          begin
            pid = IO.read(f).chomp.to_i
            Process.kill(15, pid)
            puts "Daemon stopped!" if opt.kill
            logger.info("Serial daemon stopped")
            opt.mail = YAML.load_file(s)[:last][:mail] if File.exists?(s)
            if opt.mail
              require 'pony'
              parse_opt_mail
              Pony.mail(:to => Pony.options[:to],
                      :subject => "Server status",
                      :body => "Serial daemon stopped")
            end
            FileUtils.rm_f [f,s]
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
        File.open(File.join(pid_dir,"ibutton.pid"), 'w'){|f| f.write(pid)}
        last = {:last => {:debug => opt.debug, :mail => opt.mail}}
        File.open(File.join(pid_dir,"ibutton.status"), 'w'){|f| f.write(last.to_yaml)}
      end
      # @todo
      def daemonize
        $0 = 'ibutton'
        fork do
          Process.setsid
          exit if fork
          if File.file?(File.join(pid_dir,"ibutton.pid"))
            puts "Pid file #{File.expand_path(File.join(pid_dir,'ibutton.pid'))} already exists.  Not starting."
            exit 1
          end
          store_pid(Process.pid)
          logger.info("Serial daemon started")
          puts "Daemon started!"
          Pony.mail(:to => Pony.options[:to],
                    :subject => "Server status",
                    :body => "Serial daemon started") if opt.mail
          STDIN.reopen '/dev/null'
          STDOUT.reopen '/dev/null', "a"
          STDERR.reopen STDOUT
          start
        end
      end
    end
  end
end
