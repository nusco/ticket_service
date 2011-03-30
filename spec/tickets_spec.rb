require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'rspec'
require 'rack/test'
require 'timecop'

require File.join(File.dirname(__FILE__), '../lib/tickets.rb')
ENV['RACK_ENV'] = 'test'

# Remove?
RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

describe Ticket do
  it "should expire after one hour" do
    Timecop.freeze do
      t = Ticket.new(:created_at => Time.now)
      Timecop.freeze(Ticket::DURATION) { t.should_not be_expired }
      Timecop.freeze(Ticket::DURATION + 1) { t.should be_expired }
    end
  end
end

describe "Tickets Service" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  it "should have a home page" do
    get '/'
    last_response.should be_ok
  end

  it "should show a ticket" do
    get '/ticket/abus_001/atram_002'
#    last_response.should be_ok
#    last_response.content_type.should == "image/png"
  end

  it "should refuse to show expired tickets" do
    Timecop.freeze do
      put '/ticket/abus_001/atram_002'
      Timecop.travel(10000) do
        get '/ticket/abus_001/atram_002'
        last_response.should_not be_ok
        last_response.status.should == 404
      end
    end
  end
end
