module MongoidAbility
  class MyLock
    include Mongoid::Document
    include MongoidAbility::Lock
    embedded_in :owner, polymorphic: true
  end

  class MyLock1 < MyLock
    def calculated_outcome(opts = {})
      opts.fetch(:override, outcome)
    end
  end
end
