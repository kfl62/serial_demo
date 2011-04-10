#encoding: utf-8
=begin
#IButton Control Center Tasks#
=end

class IbWebControlTsk < Sinatra::Base
  # @todo Document this method
  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :"stylesheets/#{params[:name]}", Compass.sass_engine_options
  end

end

