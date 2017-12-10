class MySubject
  include Mongoid::Document
  include MongoidAbility::Subject

  field :override, type: Boolean, default: false
end

class MySubject1 < MySubject
end

class MySubject2 < MySubject1
end
