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


describe "Ticket Service" do
  before (:each) do
    Timecop.freeze
    Ticket.destroy
  end
  
  after :each do
    Timecop.return
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

  describe "the online service" do
    include Rack::Test::Methods

    def app
      @app ||= Sinatra::Application
    end
  
    it "should have a home page" do
      get '/'
      last_response.should be_ok
    end

    describe "the Ticket resource (/ticket/[abus_code]/[atram_code])" do

      it "should PUT a new ticket" do
        put '/ticket/abus_001/atram_002'

        get '/ticket/abus_001/atram_002'
        last_response.status.should == 200
      end

      it "should GET the ticket as a .png barcode" do
        put '/ticket/abus_001/atram_002'
    
        get '/ticket/abus_001/atram_002'
        last_response.should be_ok
        last_response.content_type.should == "image/png"
      end

      it "should GET a 403 if the ticket is expired" do
        put '/ticket/abus_001/atram_002'
    
        Timecop.travel(Ticket::DURATION * 2) do
          get '/ticket/abus_001/atram_002'
          last_response.status.should == 403
        end
      end

      it "should GET a 404 if the ticket is invalid" do
        get '/ticket/abus_001/atram_002'
        last_response.status.should == 404
      end
    end
  
    describe "the CheckIns resource (/check_ins/[abus_code]/[atram_code])" do
      it "should POST a new check in" do
        put '/ticket/abus_001/atram_002'

        post '/check_ins/abus_001/atram_002'
        last_response.status.should == 200
      end

      it "should POST a 403 if the ticket is expired" do
        put '/ticket/abus_001/atram_002'
    
        Timecop.travel(Ticket::DURATION * 2) do
          post '/check_ins/abus_001/atram_002'
          last_response.status.should == 403
        end
      end

      it "should POST a 404 if the ticket is invalid" do
        post '/check_ins/abus_001/atram_002'
        last_response.status.should == 404
      end
    end

    describe "the CheckOuts resource (/check_outs/[abus_code]/[atram_code])" do
      it "should POST a new check out" do
        put '/ticket/abus_001/atram_002'

        post '/check_outs/abus_001/atram_002'
        last_response.should be_ok
      end

      it "should POST a new check out with an expired the ticket" do
        put '/ticket/abus_001/atram_002'
  
        Timecop.travel(Ticket::DURATION * 2) do
          post '/check_outs/abus_001/atram_002'
          last_response.status.should == 200
        end
      end

      it "should POST a 404 if the ticket is invalid" do
        post '/check_outs/abus_001/atram_002'
        last_response.status.should == 404
      end
    end
  end
end