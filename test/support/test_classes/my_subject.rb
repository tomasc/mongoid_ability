module MongoidAbility
  class MySubject
    include Mongoid::Document
    include MongoidAbility::Subject

    default_lock MyLock, :read, true
    default_lock MyLock1, :update, false
  end

  class MySubject1 < MySubject
    default_lock MyLock, :read, false
  end

  class MySubject2 < MySubject1
  end
end
