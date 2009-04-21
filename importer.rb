require 'rubygems'
require 'sinatra'

# File importers
require 'roo'
require 'fastercsv'

# Dreamhost API wrapper
require 'dreamy'

# options
enable :sessions


get '/' do
  haml :index
end

post '/upload' do
  @file = params[:file][:tempfile]
end

# css
get '/css/application.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :application
end