module MongoidAbility
  class MySubject
    include Mongoid::Document
    include MongoidAbility::Subject
  end

  class MySubject1 < MySubject
  end

  class MySubject2 < MySubject1
  end
end
