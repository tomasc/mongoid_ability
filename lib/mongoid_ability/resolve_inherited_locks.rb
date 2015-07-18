module MongoidAbility
  class ResolveInheritedLocks < ResolveLocks

    def call
      uo = user_outcome
      return uo if uo != nil
      if owner.respond_to?(owner.class.inherit_from_relation_name) && owner.inherit_from_relation != nil
        io = owner.inherit_from_relation.collect { |inherited_owner| inherited_owner_outcome(inherited_owner) }.compact
        return io.any?{ |o| o == true } unless io.empty?
      end
      default_outcome
    end

    private # =============================================================

    def user_outcome
      ResolveOwnerLocks.call(owner, action, subject_class, subject, options)
    end

    def inherited_owner_outcome inherited_owner
      ResolveOwnerLocks.call(inherited_owner, action, subject_class, subject, options)
    end

    def default_outcome
      ResolveDefaultLocks.call(nil, action, subject_class, nil, options)
    end

  end
end
