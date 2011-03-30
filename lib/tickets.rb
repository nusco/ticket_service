require 'rubygems'
require 'bundler/setup'
require 'sinatra'

require File.join(File.dirname(__FILE__), 'barcodes.rb')
require File.join(File.dirname(__FILE__), 'database.rb')

get '/' do
  File.read 'index.html'
end

get '/ticket/:abus_code/:atram_code' do
#  ticket = Ticket.find :abus_code => abus_code, :atram_code => atram_code
  ticket = nil
  
  halt 404 unless ticket
  
  content_type :png
  body barcode(params[:abus_code], params[:atram_code])
end

put '/ticket/:abus_code/:atram_code' do
  Ticket.create(
    :abus_code => abus_code,
    :atram_code => atram_code,
    :created_at => Time.now
  )
  content_type :png
  body ticket(params[:abus_code], params[:atram_code])
end

post '/check_ins/:abus_code/:atram_code/' do
   # TODO: return 200 or 40x
end

get '/check_ins/:abus_code/:atram_code/' do
   # TODO: return 200 or 40x
end

post '/check_outs/:abus_code/:atram_code/' do
  # TODO
end

get '/check_ins/:abus_code/:atram_code/' do
   # TODO: return 200 or 40x
end