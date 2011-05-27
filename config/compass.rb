# encoding: utf-8

if defined?(Sinatra)
  # This is the configuration to use when running within sinatra
  project_path = File.expand_path('..', File.dirname(__FILE__))
  environment = :development
else
  # this is the configuration to use when running within the compass command line tool.
  css_dir = File.join('public', 'stylesheets')
  relative_assets = true
  environment = :production
end

# This is common configuration
sass_dir = File.join('lib','ib', 'web', 'views', 'assets', 'stylesheets')
images_dir = File.join('public', 'images')
cache_dir = File.join('tmp', 'sass-cache')
http_path = '/'
http_images_path = '/images'
http_stylesheets_path = '/stylesheets'
sass_options = {:cache_location => './tmp/sass-cache'}
