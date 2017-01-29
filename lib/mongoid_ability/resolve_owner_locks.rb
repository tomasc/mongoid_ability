# OPTIMIZE: this seems quite expensive

module MongoidAbility
  class ResolveOwnerLocks < Resolver
    def call
      return unless owner.respond_to?(:locks_relation)

      locks_for_subject_type = owner.locks_relation.for_action(action).for_subject_type(subject_type).cache

      return unless locks_for_subject_type.exists?

      # return lock if owner defines lock for id
      if subject_id.present?
        id_locks = locks_for_subject_type.id_locks.for_subject_id(subject_id).cache

        closed_lock = id_locks.detect { |l| l.closed?(options) }
        return closed_lock if closed_lock

        open_lock = id_locks.detect { |l| l.open?(options) }
        return open_lock if open_lock
      end

      # return lock if owner defines lock for subject_type
      class_locks = locks_for_subject_type.class_locks.cache

      closed_lock = class_locks.class_locks.detect { |l| l.closed?(options) }
      return closed_lock if closed_lock

      open_lock = class_locks.class_locks.detect { |l| l.open?(options) }
      return open_lock if open_lock

      nil
    end
  end
end
