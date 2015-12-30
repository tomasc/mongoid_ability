module MongoidAbility
  class MyLock
    include Mongoid::Document
    include Mongoid::Timestamps
    include MongoidAbility::Lock
    
    embedded_in :owner, polymorphic: true, touch: true
  end

  class MyLock1 < MyLock
    def calculated_outcome(opts = {})
      opts.fetch(:override, outcome)
    end
  end
end
