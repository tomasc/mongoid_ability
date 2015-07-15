module MongoidAbility
  class ResolveDefaultLocks < ResolveLocks

    def call
      class_locks = subject_class.default_locks.select{ |l| l.action == action }
      return false if class_locks.any?{ |l| l.closed?(options) }
      return true if class_locks.any?{ |l| l.open?(options) }
    end

  end
end
