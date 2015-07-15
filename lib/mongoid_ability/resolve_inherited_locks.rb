module MongoidAbility
  class ResolveInheritedLocks < ResolveLocks

    def call
      uo = user_outcome
      return uo if uo != nil

      if owner.respond_to?(owner.class.roles_relation_name)
        ro = owner.roles_relation.collect { |role| role_outcome(role) }.compact
        return ro.any?{ |o| o == true } unless ro.empty?
      end

      default_outcome
    end

    private # =============================================================

    def user_outcome
      ResolveOwnerLocks.call(owner, action, subject_class, subject, options)
    end

    def role_outcome role
      ResolveOwnerLocks.call(role, action, subject_class, subject, options)
    end

    def default_outcome
      ResolveDefaultLocks.call(role, action, subject_class, subject, options)
    end

  end
end
