module MongoidAbility
  class MyOwner
    include Mongoid::Document
    include Mongoid::Timestamps
    include MongoidAbility::Owner

    embeds_many :my_locks, class_name: 'MongoidAbility::MyLock', as: :owner
    has_and_belongs_to_many :my_roles

    def self.locks_relation_name
      :my_locks
    end

    def self.inherit_from_relation_name
      :my_roles
    end
  end

  class MyOwner1 < MyOwner
  end
end
