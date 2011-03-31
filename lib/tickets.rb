require 'rubygems'
require 'bundler/setup'
require 'sinatra'

require File.join(File.dirname(__FILE__), 'barcodes.rb')
require File.join(File.dirname(__FILE__), 'database.rb')

get '/' do
  File.read 'index.html'
end

get '/ticket/:abus_code/:atram_code' do
  ticket = Ticket.first(
    :abus_code => params[:abus_code],
    :atram_code => params[:atram_code]
  )
  halt 404 unless ticket
  halt 403 if ticket.expired?
  
  content_type :png
  body barcode(params[:abus_code], params[:atram_code])
end

put '/ticket/:abus_code/:atram_code' do
  Ticket.create(
    :abus_code => params[:abus_code],
    :atram_code => params[:atram_code],
    :created_at => Time.now
  )
  
  content_type :png
  body ticket(params[:abus_code], params[:atram_code])
end

post '/check_ins/:abus_code/:atram_code' do
  ticket = Ticket.first(
    :abus_code => params[:abus_code],
    :atram_code => params[:atram_code]
  )
  halt 404 unless ticket
  halt 403 if ticket.expired?
  
  "OK"
end

post '/check_outs/:abus_code/:atram_code' do
  # TODO
end
