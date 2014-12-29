require 'bundler/setup'
require 'database_cleaner'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'mongoid'

require 'mongoid_ability'

# =====================================================================
  
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

# =====================================================================

module MongoidAbility
  class MyLock
    include Mongoid::Document
    include MongoidAbility::Lock
  end

  class MyOwnerSuper
    include Mongoid::Document
    include MongoidAbility::Owner

    # embeds_many_locks class_name: 'MongoidAbility::MyLock'
  end

  class MyOwner < MyOwnerSuper
  end

  class MySubjectSuper
    include Mongoid::Document
    include MongoidAbility::Subject
  end

  class MySubject < MySubjectSuper
    default_lock :read, true
  end
end