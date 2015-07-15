module MongoidAbility
  class InheritedLocksResolver < LocksResolver

    def outcome
      uo = user_outcome
      return uo if uo != nil

      if owner.respond_to?(owner.class.roles_relation_name)
        ro = owner.roles_relation.collect { |role| role_outcome(role) }.compact
        return ro.any?{ |o| o == true } unless ro.empty?
      end

      class_outcome
    end

    private # =============================================================

    def user_outcome
      OwnerLocksResolver.new(@owner, @action, @subject_class, @subject, @options).outcome
    end

    def role_outcome role
      OwnerLocksResolver.new(role, @action, @subject_class, @subject, @options).outcome
    end

    # TODO: make its own resolver?
    def class_outcome
      class_locks = @subject_class.default_locks.select{ |l| l.action == @action }
      return false if class_locks.any?{ |l| l.closed?(@options) }
      return true if class_locks.any?{ |l| l.open?(@options) }
    end

  end
end
