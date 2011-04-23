#encoding: utf-8

module Ib
  module Web
    module Helpers
      module Haml
        # #Haml helpers
        # Helper methods used in ... classes
        module Helpers

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
          def t(text, options={})
            I18n.reload!
            translation = I18n.t(text,options)
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
          def pretty_title(obj)
            prefix = obj.model.to_s.downcase.split('::')[-2..-1].join("_")
            t("#{prefix}.title")
          end
          # @todo
          def pretty_column_names(obj)
            retval = []
            prefix = obj.model.to_s.downcase.split('::')[-2..-1].join("_")
            obj.columns.each do |name|
              name = name.to_s
              if (name =~ /id|created_at|updated_at/) == 0
                retval << t("mdl.#{name}")
              else
                retval << t("#{prefix}.#{name}")
              end
            end
            retval
          end
        end
      end
    end
  end
end

