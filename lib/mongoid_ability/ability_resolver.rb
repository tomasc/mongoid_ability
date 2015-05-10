module MongoidAbility
  class AbilityResolver

    def initialize owner, action, subject_type, subject=nil
      @subject_class = subject_type.to_s.constantize
      
      raise StandardError, "#{subject_type} class does not have default locks" unless @subject_class.respond_to?(:default_locks)
      raise StandardError, "#{subject_type} class does not have default lock for :#{action} action" unless @subject_class.self_and_ancestors_with_default_locks.any? do |cls|
        cls.default_locks.any?{ |l| l.action == action }
      end

      @owner = owner
      @action = action.to_sym
      @subject_type = subject_type.to_s
      @subject = subject
      @subject_id = subject.id if subject.present?
    end

    # ---------------------------------------------------------------------
    
    def outcome
      locks_for_subject_type = @owner.locks_relation.for_action(@action).for_subject_type(@subject_type)

      return unless locks_for_subject_type.exists?

      # return outcome if owner defines lock for id
      if @subject.present?
        id_locks = locks_for_subject_type.id_locks.for_subject_id(@subject_id)
        return false if id_locks.any?(&:closed?)
        return true if id_locks.any?(&:open?)
      end

      # return outcome if owner defines lock for subject_type
      class_locks = locks_for_subject_type.class_locks
      return false if class_locks.class_locks.any?(&:closed?)
      return true if class_locks.class_locks.any?(&:open?)

      nil
    end

  end
end