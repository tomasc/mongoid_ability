class MyLock
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidAbility::Lock

  embedded_in :owner, polymorphic: true

  # Mongoid 7 does not support `touch: true` on polymorphic associations
  after_save -> { owner.touch if owner? }
  after_destroy -> { owner.touch if owner? }
  after_touch -> { owner.touch if owner? }
end

class MyLock1 < MyLock
end
