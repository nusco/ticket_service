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

  before :all do
    Timecop.freeze
  end
  
  after :all do
    Timecop.return
  end
  
  it "should have a home page" do
    get '/'
    last_response.should be_ok
  end

  describe "the Ticket resource (/ticket/[abus_code]/[atram_code])" do
    it "should GET the ticket as a .png barcode" do
      Timecop.freeze do
        put '/ticket/abus_001/atram_002'
      
        get '/ticket/abus_001/atram_002'
        last_response.should be_ok
        last_response.content_type.should == "image/png"
      end
    end

    it "should GET a 400 if the ticket is expired" do
      Timecop.freeze do
        put '/ticket/abus_001/atram_002'
      
        Timecop.travel(10000) do
          get '/ticket/abus_001/atram_002'
          last_response.status.should == 403
        end
      end
    end

    it "should GET a 404 if the ticket is invalid" do
      get '/ticket/abus_000/atram_999'
      last_response.status.should == 404
    end
  end
end
