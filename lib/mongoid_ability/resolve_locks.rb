module MongoidAbility
  class ResolveLocks < Resolver
    def call
      lock = nil
      subject_class.self_and_ancestors_with_default_locks.each do |cls|
        lock = ResolveInheritedLocks.call(owner, action, cls.to_s, subject_id, options)
        break unless lock.nil?
      end
      lock
    end
  end
end
