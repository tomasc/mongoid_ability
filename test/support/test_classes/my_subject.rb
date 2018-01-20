class MySubject
  include Mongoid::Document
  include MongoidAbility::Subject

  field :str_val, type: String
  field :override, type: Boolean, default: false
end

class MySubject1 < MySubject
end

class MySubject11 < MySubject
end

class MySubject2 < MySubject1
end

class MySubject21 < MySubject11
end
