require 'bundler/setup'
require 'database_cleaner'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'mongoid'

require 'mongoid_ability'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# if ENV['CI']
#   require 'coveralls'
#   Coveralls.wear!
# end

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO

Mongoid.configure do |config|
  config.connect_to('mongoid_ability_test')
end

DatabaseCleaner.orm = :mongoid
DatabaseCleaner.strategy = :truncation

class MiniTest::Spec
  before(:each) do
    DatabaseCleaner.start
  end

  after(:each) do
    [ MySubject,
      MySubject1, MySubject2,
      MySubject11, MySubject21
    ].each(&:reset_default_locks!)

    DatabaseCleaner.clean
  end
end

class Object
  include MongoidAbility::Expectations
end
