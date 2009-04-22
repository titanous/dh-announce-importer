require 'rubygems'
require 'sinatra'
require 'json'

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
  puts @file.path
  sleep 10
  return '1'
end

post '/authenticate' do
  domains = []
  
  @dh_account = Dreamy::Base.new(params[:login], params[:api_key])
  
  begin
    @dh_account.domains.each { |domain| domains << domain.domain }
  rescue Dreamy::ApiError
    return 'LOGINERROR'
  end
  
  content_type 'application/json', :charset => 'utf-8'
  return JSON.generate(domains)
end

# css
get '/stylesheets/application.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :application
end