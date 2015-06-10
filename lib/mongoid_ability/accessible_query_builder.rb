module MongoidAbility
  class AccessibleQueryBuilder < Struct.new(:base_class, :ability, :action)

    def self.call *args
      new(*args).call
    end

    # =====================================================================

    def call
      criteria = base_criteria

      base_class_and_descendants.each do |cls|
        criteria = criteria.merge(criteria_for_class(cls))
      end

      criteria
    end

    private # =============================================================

    def base_criteria
      @base_criteria ||= base_class.criteria
    end

    # ---------------------------------------------------------------------

    def base_class_superclass
      @base_class_superclass ||= (base_class.ancestors_with_default_locks.last || base_class)
    end

    def base_class_descendants
      @base_class_descendants ||= ObjectSpace.each_object(Class).select{ |cls| cls < base_class_superclass }
    end

    def base_class_and_descendants
      [base_class].concat(base_class_descendants)
    end

    def hereditary?
      base_class_and_descendants.count > 1
    end

    # ---------------------------------------------------------------------

    def user
      ability.user
    end

    def roles
      user.roles_relation
    end

    # ---------------------------------------------------------------------

    def user_id_locks_for_subject_type cls
      user.locks_relation.id_locks.for_action(action).for_subject_type(cls.to_s)
    end

    def roles_ids_locks_for_subject_type cls
      roles.collect { |role| role.locks_relation.id_locks.for_action(action).for_subject_type(cls.to_s) }.flatten
    end

    # ---------------------------------------------------------------------

    def role_has_open_id_lock? cls, subject_id
      roles_ids_locks_for_subject_type(cls).
        select(&:open?).
        map(&:subject_id).
        include?(subject_id)
    end

    def user_has_open_id_lock? cls, subject_id
      user_id_locks_for_subject_type(cls).
        select(&:open?).
        map(&:subject_id).
        include?(subject_id)
    end

    # ---------------------------------------------------------------------

    def criteria_for_class cls
      ability.can?(action, cls) ? exclude_criteria(cls) : include_criteria(cls)
    end

    def exclude_criteria cls
      id_locks = roles_ids_locks_for_subject_type(cls).select(&:closed?)
      id_locks = id_locks.reject{ |lock| role_has_open_id_lock?(cls, lock.subject_id) }
      id_locks = id_locks.reject{ |lock| user_has_open_id_lock?(cls, lock.subject_id) }
      id_locks += user_id_locks_for_subject_type(cls).select(&:closed?)

      excluded_ids = id_locks.map(&:subject_id).flatten

      conditions = { :_id.nin => excluded_ids }
      conditions = conditions.merge(_type: cls.to_s) if hereditary?

      base_criteria.or(conditions)
    end

    def include_criteria cls
      id_locks = roles_ids_locks_for_subject_type(cls).select(&:open?)
      id_locks += user_id_locks_for_subject_type(cls).select(&:open?)

      included_ids = id_locks.map(&:subject_id).flatten

      conditions = { :_id.in => included_ids }
      conditions = conditions.merge(_type: cls.to_s) if hereditary?

      base_criteria.or(conditions)
    end

  end
end
