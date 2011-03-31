require 'dm-core'
DataMapper.setup(:default, 'sqlite::memory:')

class Ticket
  DURATION =3600
  include DataMapper::Resource

  property :id         , Serial
  property :created_at , Time
  property :abus_code  , String, :unique => true
  property :atram_code , String, :unique => true
  
  def expired?
    Time.now - created_at > DURATION
  end
  
  def self.retrieve(abus_code, atram_code)
    Ticket.first :abus_code => abus_code, :atram_code => atram_code
  end
end

DataMapper.finalize

require  'dm-migrations'
DataMapper.auto_migrate!
