require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'rspec'
require 'rack/test'
require 'timecop'

require File.join(File.dirname(__FILE__), '../lib/tickets.rb')
ENV['RACK_ENV'] = 'test'

describe "Ticket Service documentation" do
  before (:each) do
    Timecop.freeze
    Ticket.destroy
  end
  
  after :each do
    Timecop.return
  end

  describe "A Ticket..." do
    it "...expires after one hour" do
      Timecop.freeze do
        t = Ticket.new(:created_at => Time.now)
        Timecop.freeze(Ticket::DURATION) { t.should_not be_expired }
        Timecop.freeze(Ticket::DURATION + 1) { t.should be_expired }
      end
    end
  end

  describe "The online REST service..." do
    include Rack::Test::Methods

    def app
      @app ||= Sinatra::Application
    end
  
    it "...has documentation at the root" do
      get '/'
      last_response.should be_ok
    end

    describe "By accessing a Ticket (/ticket/[abus_code]/[atram_code]), you:" do

      it "PUT a new ticket" do
        put '/ticket/abus_001/atram_002'

        get '/ticket/abus_001/atram_002'
        last_response.status.should == 200
      end

      it "GET a ticket as a .png barcode" do
        put '/ticket/abus_001/atram_002'
    
        get '/ticket/abus_001/atram_002'
        last_response.should be_ok
        last_response.content_type.should == "image/png"
      end

      it "GET a 403 if the ticket is expired" do
        put '/ticket/abus_001/atram_002'
    
        Timecop.travel(Ticket::DURATION * 2) do
          get '/ticket/abus_001/atram_002'
          last_response.status.should == 403
        end
      end

      it "GET a 404 if the ticket is invalid" do
        get '/ticket/abus_001/atram_002'
        last_response.status.should == 404
      end
    end
  
    describe "By accessing CheckIns (/check_ins/[abus_code]/[atram_code]), you:" do
      it "POST a new check in" do
        put '/ticket/abus_001/atram_002'

        post '/check_ins/abus_001/atram_002'
        last_response.status.should == 200
      end

      it "POST a 403 if the ticket is expired" do
        put '/ticket/abus_001/atram_002'
    
        Timecop.travel(Ticket::DURATION * 2) do
          post '/check_ins/abus_001/atram_002'
          last_response.status.should == 403
        end
      end

      it "POST a 404 if the ticket is invalid" do
        post '/check_ins/abus_001/atram_002'
        last_response.status.should == 404
      end
    end

    describe "By accessing CheckOuts (/check_outs/[abus_code]/[atram_code]), you:" do
      it "POST a new check out" do
        put '/ticket/abus_001/atram_002'

        post '/check_outs/abus_001/atram_002'
        last_response.should be_ok
      end

      it "POST a new check out with an expired ticket" do
        put '/ticket/abus_001/atram_002'
  
        Timecop.travel(Ticket::DURATION * 2) do
          post '/check_outs/abus_001/atram_002'
          last_response.status.should == 200
        end
      end

      it "POST a 404 if the ticket is invalid" do
        post '/check_outs/abus_001/atram_002'
        last_response.status.should == 404
      end
    end
  end
end