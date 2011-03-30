# TODO: switch to postgres for production
require 'dm-core'
DataMapper.setup(:default, 'sqlite::memory:')

require File.join(File.dirname(__FILE__), 'model.rb')
DataMapper.finalize

require  'dm-migrations'
DataMapper.auto_migrate!