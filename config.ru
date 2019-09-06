require 'rubygems'
require 'bundler'

Bundler.require

set :root, File.dirname(__FILE__)
set :views, File.expand_path("front_end/views", settings.root)
set :public_folder, File.expand_path("front_end/public", settings.root)
require File.expand_path("front_end/app.rb", settings.root)
run Sinatra::Application
