module MongoidAbility
  class AbilityResolver

    def initialize user, action, subject_type, subject=nil
      @subject_class = subject_type.to_s.constantize
      
      raise StandardError, "#{subject_type} class does not have default locks" unless @subject_class.respond_to?(:default_locks)
      raise StandardError, "#{subject_type} class does not have default lock for :#{action} action" unless @subject_class.self_and_ancestors_with_default_locks.any? do |cls|
        cls.default_locks.any?{ |l| l.action == action }
      end

      @user = user
      @action = action.to_sym
      @subject_type = subject_type.to_s
      @subject = subject
      @subject_id = subject.id if subject.present?
    end

    # ---------------------------------------------------------------------
    
    def outcome
      ua = user_outcome
      return ua unless ua.nil?

      ra = roles_outcome
      return ra unless ra.nil?

      class_outcome
    end

    # ---------------------------------------------------------------------

    def user_outcome
      locks_for_subject_type = @user.locks.for_action(@action).for_subject_type(@subject_type)

      return unless locks_for_subject_type.exists?

      # return outcome if user defines lock for id
      if @subject.present?
        id_locks = locks_for_subject_type.id_locks.for_subject_id(@subject_id)
        return false if id_locks.closed.exists?
        return true if id_locks.open.exists?
      end

      # return outcome if user defines lock for subject_type
      class_locks = locks_for_subject_type.class_locks
      return false if class_locks.class_locks.closed.exists?
      return true if class_locks.class_locks.open.exists?
    end

    # ---------------------------------------------------------------------

    def roles_outcome
      locks_for_subject_type = @user.roles_relation.collect(&:locks).flatten.select{ |l| l.subject_type == @subject_type && l.action == @action }

      return unless locks_for_subject_type.present?

      # return outcome if any role defines lock for id
      if @subject.present?
        id_locks = locks_for_subject_type.select{ |l| l.subject_id == @subject_id }
        # for same role, prefer closed lock
        id_locks = id_locks.reject{ |l| l.open? && id_locks.any?{ |ol| ol.closed? && ol.owner == l.owner } }
        # across multiple roles, prefer open lock
        return true if id_locks.any?(&:open?)
        return false if id_locks.any?(&:closed?)
      end

      # for same role prefer closed lock
      class_locks = locks_for_subject_type.reject(&:id_lock?)
      class_locks = class_locks.reject{ |l| l.open? && class_locks.any?{ |ol| ol.closed? && ol.owner == l.owner } }

      # across multiple roles, prefer open lock
      return true if class_locks.any?(&:open?)
      return false if class_locks.any?(&:closed?)
    end

    # ---------------------------------------------------------------------

    def class_outcome
      class_locks = @subject_class.default_locks.select{ |l| l.action == @action }

      return false if class_locks.any?(&:closed?)
      return true if class_locks.any?(&:open?)
    end

  end
end