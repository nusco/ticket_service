require 'rubygems'
require 'bundler/setup'
require 'sinatra'

require File.join(File.dirname(__FILE__), 'model.rb')

get '/' do
  content_type :text
  File.read 'api.txt'
end

put '/tickets/:abus_code/:atram_code' do
  Ticket.create(
    :abus_code  => params[:abus_code],
    :atram_code => params[:atram_code],
    :created_at => Time.now
  )
  
  content_type :png
  ticket.to_barcode
end

get '/tickets/:abus_code/:atram_code' do
  ticket = Ticket.retrieve params[:abus_code], params[:atram_code]
  halt(404, 'Invalid ticket') unless ticket
  halt(403, 'Your ticket has expired') if ticket.expired?
  
  content_type :png
  ticket.to_barcode
end

post '/check_ins/:abus_code/:atram_code' do
  ticket = Ticket.retrieve params[:abus_code], params[:atram_code]
  halt(404, 'Invalid ticket') unless ticket
  halt(403, 'Your ticket has expired') if ticket.expired?
end

post '/check_outs/:abus_code/:atram_code' do
  ticket = Ticket.retrieve params[:abus_code], params[:atram_code]
  halt(404, 'Invalid ticket') unless ticket
end
