#encoding: utf-8
=begin
#IButton Control Center#
=end

class IbWebControl < Sinatra::Base
  # @todo Document this method
  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :"stylesheets/#{params[:name]}", Compass.sass_engine_options
  end

  # @todo Document this method
  get '/' do
    haml :'control/index', :layout => :'./layouts/default'
  end
  
end

