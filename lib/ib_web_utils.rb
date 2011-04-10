#encoding: utf-8
=begin
#Handling utilities#
=end
class IbWebUtils < Sinatra::Base
  # @todo Document this method
  get '/msg/:what/:kind' do |w,k|
    if w == 'flash'
      retval = flash[:msg]
    else
      retval = {:msg => {:txt => I18n.t(w, :data => params[:data]), :class => k}}.to_json
    end
    retval
  end
  # @todo Document this method
  get '/lang/:lang' do |l|
    I18n.locale = l.to_sym
    path = logged_in? ?  "#{lang_path}/cc" :  "#{lang_path}/"
    flash[:msg] = {:msg => {:txt => I18n.t('lang.change'), :class => "info"}}.to_json
    redirect path
  end
end

