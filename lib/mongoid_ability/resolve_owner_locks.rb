# OPTIMIZE: this seems quite expensive

module MongoidAbility
  class ResolveOwnerLocks < ResolveLocks
    def call
      return unless owner.respond_to?(:locks_relation)

      locks_for_subject_type = owner.locks_relation.for_action(action).for_subject_type(subject_type).cache

      return unless locks_for_subject_type.exists?

      # return outcome if owner defines lock for id
      if subject_id.present?
        id_locks = locks_for_subject_type.id_locks.for_subject_id(subject_id).cache
        return false if id_locks.any? { |l| l.closed?(options) }
        return true if id_locks.any? { |l| l.open?(options) }
      end

      # return outcome if owner defines lock for subject_type
      class_locks = locks_for_subject_type.class_locks.cache
      return false if class_locks.class_locks.any? { |l| l.closed?(options) }
      return true if class_locks.class_locks.any? { |l| l.open?(options) }

      nil
    end
  end
end
