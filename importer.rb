require 'rubygems'
require 'sinatra'
require 'roo'
require 'dreamy'

get '/' do
  haml :index
end

get '/css/application.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :application
end