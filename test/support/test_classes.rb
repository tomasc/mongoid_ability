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

class SubjectSingleTest
  include Mongoid::Document
  include MongoidAbility::Subject

  default_lock :read, true
end

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