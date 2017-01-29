module MongoidAbility
  class ResolveInheritedLocks < ResolveLocks
    def call
      owner_lock = resolved_owner_lock
      return owner_lock if owner_lock

      if owner.respond_to?(owner.class.inherit_from_relation_name) && !owner.inherit_from_relation.nil?
        resolved_inherited_owner_locks = owner.inherit_from_relation.map { |inherited_owner| resolved_inherited_owner_lock(inherited_owner) }.compact

        open_lock = resolved_inherited_owner_locks.detect { |l| l.open?(options) }
        return open_lock if open_lock

        closed_lock = resolved_inherited_owner_locks.detect { |l| l.closed?(options) }
        return closed_lock if closed_lock
      end

      resolved_default_lock
    end

    private

    def resolved_owner_lock
      @resolved_owner_lock ||= ResolveOwnerLocks.call(owner, action, subject_class, subject, options)
    end

    def resolved_inherited_owner_lock(inherited_owner)
      @resolved_inherited_owner_lock ||= {}
      @resolved_inherited_owner_lock[inherited_owner] ||= ResolveOwnerLocks.call(inherited_owner, action, subject_class, subject, options)
    end

    def resolved_default_lock
      @resolved_default_lock ||= ResolveDefaultLocks.call(nil, action, subject_class, nil, options)
    end
  end
end
