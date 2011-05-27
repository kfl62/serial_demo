#encoding: utf-8
require 'bundler/setup'
require 'compass'
require 'sinatra/base'
require 'rack-flash'
require 'rack/rewrite'
require 'haml'
require 'sass'
require 'rdiscount'
require 'json'
require './lib/ib'

run Ib::Web.server
