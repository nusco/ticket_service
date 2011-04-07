require 'rubygems'
require 'bundler/setup'
require 'rake'

desc "Generate the home page documentation"
task :build_home do
  exec 'bundle exec rspec spec -f d -o api.txt'
end
