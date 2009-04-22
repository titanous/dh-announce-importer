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

post '/authenticate' do
  domains = []
  
  dh_account = Dreamy::Base.new(params[:login], params[:api_key])
  
  begin
    dh_account.domains.each { |domain| domains << domain.domain }
  rescue Dreamy::ApiError
    return 'LOGINERROR'
  end
  
  session[:dh_account] = dh_account
  
  content_type 'application/json', :charset => 'utf-8'
  return JSON.generate(domains)
end

post '/check_list' do
  session[:subscriber_list] = []
  dh_account = session[:dh_account]
  
  content_type 'text/plain', :charset => 'utf-8'
  
  begin
    dh_account.announce_list(params[:list], params[:domain]).each { |subscriber| session[:subscriber_list] << subscriber.email }
  rescue Dreamy::ApiError
    return 'LISTERROR'
  end
  
  return 'VALID'
end

post '/upload' do
  file = params[:file][:tempfile]

  return '1'
end

# css
get '/stylesheets/application.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :application
end