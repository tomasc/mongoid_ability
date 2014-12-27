require 'bundler/setup'
require 'database_cleaner'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'mongoid'

if ENV["CI"]
  require "coveralls"
  Coveralls.wear!
end

ENV["MONGOID_TEST_HOST"] ||= "localhost"
ENV["MONGOID_TEST_PORT"] ||= "27017"

HOST = ENV["MONGOID_TEST_HOST"]
PORT = ENV["MONGOID_TEST_PORT"].to_i

def database_id
  "mongoid_ability_test"
end

CONFIG = {
  sessions: {
    default: {
      database: database_id,
      hosts: [ "#{HOST}:#{PORT}" ]
    }
  }
}

Mongoid.configure do |config|
  config.load_configuration(CONFIG)
end

DatabaseCleaner.orm = :mongoid
DatabaseCleaner.strategy = :truncation

class MiniTest::Spec
  before(:each) { DatabaseCleaner.start }
  after(:each) { DatabaseCleaner.clean }
end
