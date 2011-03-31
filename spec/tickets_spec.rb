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
    Ticket.destroy
    Timecop.freeze
  end
  
  after :each do
    Timecop.return
  end

  describe "A Ticket:" do
    it "expires after one hour" do
      t = Ticket.new(:created_at => Time.now)
      Timecop.freeze(Ticket::DURATION) { t.should_not be_expired }
      Timecop.freeze(Ticket::DURATION + 1) { t.should be_expired }
    end
  end

  describe "Ticket Service API:" do
    include Rack::Test::Methods

    def app
      @app ||= Sinatra::Application
    end
  
    describe "The root resource (/):" do
      describe "GET" do
        it "returns this documentation" do
          get '/'
          last_response.should be_ok
        end
      end
    end
    
    describe "The Ticket resource (/ticket/[abus_code]/[atram_code]):" do
      describe "PUT" do
        it "creates a new ticket" do
          put '/ticket/abus_001/atram_002'

          get '/ticket/abus_001/atram_002'
          last_response.status.should == 200
        end
      end

      describe "GET" do
        it "returns the ticket as a .png barcode" do
          put '/ticket/abus_001/atram_002'
    
          get '/ticket/abus_001/atram_002'
          last_response.status.should == 200
          last_response.content_type.should == "image/png"
        end

        it "returns a 403 if the ticket is expired" do
          put '/ticket/abus_001/atram_002'
    
          Timecop.travel(Ticket::DURATION * 2) do
            get '/ticket/abus_001/atram_002'
            last_response.status.should == 403
          end
        end

        it "returns a 404 if the ticket is invalid" do
          get '/ticket/abus_001/atram_002'
          last_response.status.should == 404
        end
      end
    end
  
    describe "The CheckIns resource (/check_ins/[abus_code]/[atram_code]):" do
      describe "POST" do
        it "creates a new check in" do
          put '/ticket/abus_001/atram_002'

          post '/check_ins/abus_001/atram_002'
          last_response.status.should == 200
        end

        it "returns a 403 if the ticket is expired" do
          put '/ticket/abus_001/atram_002'
    
          Timecop.travel(Ticket::DURATION * 2) do
            post '/check_ins/abus_001/atram_002'
            last_response.status.should == 403
          end
        end

        it "returns a 404 if the ticket is invalid" do
          post '/check_ins/abus_001/atram_002'
          last_response.status.should == 404
        end
      end
    end
    
    describe "The CheckOuts resource (/check_outs/[abus_code]/[atram_code]):" do
      describe "POST" do
        it "creates a new check out" do
          put '/ticket/abus_001/atram_002'

          post '/check_outs/abus_001/atram_002'
          last_response.status.should == 200
        end

        it "still creates a check out if the ticket is expired" do
          put '/ticket/abus_001/atram_002'
  
          Timecop.travel(Ticket::DURATION * 2) do
            post '/check_outs/abus_001/atram_002'
            last_response.status.should == 200
          end
        end

        it "returns a 404 if the ticket is invalid" do
          post '/check_outs/abus_001/atram_002'
          last_response.status.should == 404
        end
      end
    end
  end
end