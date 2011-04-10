#encoding: utf-8
require './config/ib_web_config'
require 'rack-flash'
require 'rack/rewrite'

use Rack::Session::Cookie, :secret => 'zsdgryst34kkufklfSwsqwess'
use Rack::Flash
use Rack::Rewrite do
  rewrite %r{^/\w{2}/utils}, '/utils'
  rewrite %r{^/\w{2}/srv},   '/cc'
  rewrite %r{^/\w{2}/},      '/'
end

map '/utils' do
  run IbWebUtils.new
end

map '/cc' do
  map '/tsk' do
    run IbWebControlTsk.new
  end
  map '/' do
    run IbWebControl.new
  end
end

map '/' do
  run IbWebPublic.new
end
