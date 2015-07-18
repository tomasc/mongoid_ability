module MongoidAbility
  class ResolveDefaultLocks < ResolveLocks

    def call
      return false if default_locks.any?{ |l| l.closed?(options) }
      return true if default_locks.any?{ |l| l.open?(options) }
    end

    private # =============================================================

    def default_locks
      subject_class.default_locks.for_action(action)
    end
  end
end
