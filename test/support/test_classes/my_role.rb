class MyRole
  include Mongoid::Document
  include MongoidAbility::Owner

  embeds_many :my_locks, class_name: 'MyLock', as: :owner
  has_and_belongs_to_many :my_owners

  def self.locks_relation_name
    :my_locks
  end
end

class MyRole1 < MyRole
end
