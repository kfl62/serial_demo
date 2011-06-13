#encoding: utf-8

module Ib
  module Web
    # Just for convenience, namespace
    module Helpers
      # #Ib::Web::Helpers::Haml module
      # ##Description
      # ##Scope
      # @todo document this module
      module Haml
        # stolen from http://gist.github.com/119874 and made a tiny bit more robust by me
        # this implementation uses haml by default. if you want to use any other template mechanism
        # then replace `haml` on line 20 and line 23 with `erb` or whatever
        def partial(template, *args)
          template_array = template.to_s.split('/')
          template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
          options = args.last.is_a?(Hash) ? args.pop : {}
          options.merge!(:layout => false)
          if collection = options.delete(:collection) then
            collection.inject([]) do |buffer, member|
              buffer << haml(:"#{template}", options.merge(:layout => false, :locals => {template_array[-1].to_sym => member}))
            end.join("\n")
          else
            haml(:"#{template}", options)
          end
        end

        # @return [String]
        # @todo Document this method
        def t(*args)
          I18n.reload!
          I18n::t(*args)
        end
        # @return [String]
        # @todo Document this method
        def current_lang
          I18n.locale
        end
        # get the current language path
        # @example
        #   "#{lang_path}#{controller_path}" #=> "/en/srv"
        # @return [String] used to format url
        def lang_path
          current_lang == I18n.default_locale ? retval = "" : retval = "/#{current_lang.to_s}"
          retval
        end
        # @return [String]
        # @todo Document this method
        def current_controller
          self.class.to_s
        end
        # get the current controller path
        # @example
        #   "#{lang_path}#{controller_path}" #=> "/hu/ctrl"
        # @return [String] used to format url
        def controller_path
          current_controller == 'Control' ? retval = '/ctrl' : retval = ''
          retval
        end
        # @todo
        # @return [String]
        def crud_title(obj,action)
          model = obj.model.name.split('::')[-1]
          table = obj.model.table_name.to_s
          action = t("crud.action.#{action}")
          t("crud.title", :model => model, :table => table, :action => action)
        end
         # @todo
        # @return [String]
        def association_title(obj)
          ary = obj.split('/')
          what = ary[0].split('_')[1]
          with = (what == 'permission') ? "all related" : ary[1].split('_')[1]
          t("associate.title", :what => what.capitalize, :with => with.capitalize)
        end
        # @todo
        def uptime(ctime)
          diff = Time.now - ctime
          sec  = diff.modulo(60)
          min  = diff.divmod(60)[0].modulo(60)
          hour = diff.divmod(60)[0].divmod(60)[0].modulo(60)
          day  = diff.divmod(60)[0].divmod(60)[0].divmod(60)[0].modulo(24)
          "%d days-%02d:%02d:%02d" % [day,hour,min,sec]
        end
        # @todo
        def hex_files
          retval = Dir.glob(File.join(settings.app_root,'vendor','firmware','*.hex'))
          retval = retval.sort{|x,y| (y[/_(.+)\./,1] || '0000') <=> (x[/_(.+)\./,1] || '0000')}
          retval.map{|f| [File.basename(f), File.basename(f,'.hex')]}
        end
      end
    end
  end
end

