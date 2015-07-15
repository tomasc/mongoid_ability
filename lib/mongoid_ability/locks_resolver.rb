module MongoidAbility
  class LocksResolver

    def initialize owner, action, subject_type, subject, options={}
      @owner = owner
      @action = action.to_sym

      @subject_type = subject_type.to_s
      @subject_class = subject_type.to_s.constantize

      @subject = subject
      @subject_id = subject.id if subject.present?

      @options = options

      raise StandardError, "#{subject_type} class does not have default locks" unless @subject_class.respond_to?(:default_locks)
      raise StandardError, "#{subject_type} class does not have default lock for :#{action} action" unless @subject_class.self_and_ancestors_with_default_locks.any? do |cls|
        cls.default_locks.any?{ |l| l.action == action }
      end
    end

  end
end
