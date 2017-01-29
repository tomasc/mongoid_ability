module MongoidAbility
  class ResolveDefaultLocks < ResolveLocks
    def call
      closed_lock = default_locks.detect { |l| l.closed?(options) }
      return closed_lock if closed_lock

      open_lock = default_locks.detect { |l| l.open?(options) }
      return open_lock if open_lock
    end

    private

    def default_locks
      subject_class.default_locks.select { |l| l.action.to_s == action.to_s }
    end
  end
end
