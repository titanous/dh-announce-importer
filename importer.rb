require 'rubygems'
require 'sinatra'
require 'extlib'
require 'json'
require 'digest/sha1'

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
    content_type 'text/plain', :charset => 'utf-8'
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
  file = File.join(File.dirname(__FILE__), 'uploads', "#{Digest::SHA1.hexdigest(Time.now.to_s)}_#{params[:file][:filename]}")
  FileUtils.mv params[:file][:tempfile].path, file
  
  rows = []
  
  begin
    case file.split('.').last # file extension
    when 'csv'
      rows = FasterCSV.read(file)
    when 'tsv'
      rows = FasterCSV.read(file, :col_sep => "\t")
    when 'xls'
      spreadsheet = Excel.new(file)
      (1..spreadsheet.last_row).each { |row| rows << spreadsheet.row(row) }
    when 'xlsx'
      spreadsheet = Excelx.new(file)
      (1..spreadsheet.last_row).each { |row| rows << spreadsheet.row(row) }
    when 'ods'
      spreadsheet = Openoffice.new(file)
      sheet = spreadsheet.sheets.first
      (1..spreadsheet.last_row(sheet)).each { |row| rows << spreadsheet.row(row, sheet) }
    end
  rescue Exception
    content_type 'text/plain', :charset => 'utf-8'
    return 'BADFILE'
  end
  
  session[:spreadsheet] = rows
  FileUtils.rm file
  
  content_type 'application/json', :charset => 'utf-8'
  email_regex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  if !rows.first.grep(email_regex).blank? # no header
    email_column = rows.first.index(rows.first.grep(email_regex).first)
    name_column = email_column == 1 ? 0 : email_column + 1
    return JSON.generate :row => rows.first, :email_column => email_column, :name_column => name_column
  elsif !rows[1].grep(email_regex).blank? # header
    email_column = rows[1].index(rows[1].grep(email_regex).first)
    name_column = email_column == 1 ? 0 : email_column + 1
    return JSON.generate :header => rows.first, :row => rows[1], :email_column => email_column, :name_column => name_column
  else
    content_type 'text/plain', :charset => 'utf-8'
    return 'NOEMAIL'
  end
end

# css
get '/stylesheets/application.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :application
end