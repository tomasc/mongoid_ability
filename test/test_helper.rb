require 'bundler/setup'
require 'database_cleaner'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'mongoid'

require 'mongoid_ability'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

if ENV["CI"]
  require "coveralls"
  Coveralls.wear!
end

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO

Mongoid.configure do |config|
  config.connect_to('mongoid_ability_test')
end

DatabaseCleaner.orm = :mongoid
DatabaseCleaner.strategy = :truncation

class MiniTest::Spec
  before(:each) { DatabaseCleaner.start }
  after(:each) { DatabaseCleaner.clean }
end
