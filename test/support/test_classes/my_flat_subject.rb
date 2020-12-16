# frozen_string_literal: true

class MyFlatSubject
  include Mongoid::Document
  include MongoidAbility::Subject

  field :str_val, type: String
  field :override, type: Boolean, default: false
end
