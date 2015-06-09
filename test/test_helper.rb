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

class TestLock
  include Mongoid::Document
  include MongoidAbility::Lock

  embedded_in :owner, polymorphic: true
end

class TestLockSub < TestLock
end

# ---------------------------------------------------------------------
  
class TestOwnerSuper
  include Mongoid::Document
  include MongoidAbility::Owner

  embeds_many :test_locks, class_name: 'TestLock', as: :owner
end

class TestOwner < TestOwnerSuper
end

# ---------------------------------------------------------------------

class SubjectTest
  include Mongoid::Document
  include MongoidAbility::Subject

  default_lock :read, true
end

class SubjectTestOne < SubjectTest
end

class SubjectTestTwo < SubjectTest
end



# class EmbeddedTestSubjectOwner
#   include Mongoid::Document
#   include MongoidAbility::Subject

#   embeds_many :embedded_test_subjects
# end

# class EmbeddedTestSubject < TestSubject
#   embedded_in :embedded_test_subject_owner
# end

# class EmbeddedTestSubjectTwo < TestSubject
#   embedded_in :embedded_test_subject_owner
# end

# ---------------------------------------------------------------------
  
class TestAbilityResolverSubject
  include Mongoid::Document
  include MongoidAbility::Subject

  default_lock :read, true
end

class TestAbilitySubjectSuper2
  include Mongoid::Document
  include MongoidAbility::Subject

  default_lock :read, false
  default_lock :update, true
end

class TestAbilitySubjectSuper1 < TestAbilitySubjectSuper2
end

class TestAbilitySubject < TestAbilitySubjectSuper1
end

# ---------------------------------------------------------------------
  
class TestRole
  include Mongoid::Document
  include MongoidAbility::Owner

  field :name, type: String

  embeds_many :test_locks, class_name: 'TestLock', as: :owner
  has_and_belongs_to_many :users, class_name: 'TestUser'
end  

class TestUser
  include Mongoid::Document
  include MongoidAbility::Owner

  embeds_many :test_locks, class_name: 'TestLock', as: :owner
  has_and_belongs_to_many :roles, class_name: 'TestRole'
end