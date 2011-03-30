class Ticket
  DURATION =3600
  
  include DataMapper::Resource

  property :id,         Serial
  property :abus_code,  String
  property :atram_code, String
  property :created_at, Time
  
  def expired?
    Time.now - created_at > DURATION
  end
end
