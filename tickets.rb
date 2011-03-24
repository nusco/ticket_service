require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'barcodes'

get '/ticket/:abus_code/:atram_code' do
  # or return 40x
  content_type :png
  body barcode(params[:abus_code], params[:atram_code])
end

put '/ticket/:abus_code/:atram_code' do
  content_type :png
  body ticket(params[:abus_code], params[:atram_code])
end

post '/check_ins/:abus_code/:atram_code/' do
   # return 200 or 40x
end

post '/check_outs/:abus_code/:atram_code/' do
  # todo
end
