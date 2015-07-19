module MongoidAbility
  class AccessibleQueryBuilder < Struct.new(:base_class, :ability, :action, :options)

    def self.call *args
      new(*args).call
    end

    # =====================================================================

    def call
      criteria = base_criteria
      base_class_and_descendants.each { |cls| criteria = criteria.merge(criteria_for_class(cls)) }
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
      @base_class_and_descendants ||= [base_class].concat(base_class_descendants)
    end

    def hereditary?
      base_class_and_descendants.count > 1
    end

    # ---------------------------------------------------------------------

    def owner
      @owner ||= ability.owner
    end

    def inherited_from_relation
      return unless owner.respond_to?(owner.class.inherit_from_relation_name)
      owner.inherit_from_relation
    end

    # ---------------------------------------------------------------------

    def owner_id_locks_for_subject_type cls
      @owner_id_locks_for_subject_type ||= {}
      @owner_id_locks_for_subject_type[cls] ||= owner.locks_relation.id_locks.for_action(action).for_subject_type(cls.to_s)
    end

    def inherited_from_relation_ids_locks_for_subject_type cls
      return [] unless inherited_from_relation
      @inherited_from_relation_ids_locks_for_subject_type ||= {}
      @inherited_from_relation_ids_locks_for_subject_type[cls] ||= inherited_from_relation.collect { |o|
        o.locks_relation.id_locks.for_action(action).for_subject_type(cls.to_s)
      }.flatten
    end

    # ---------------------------------------------------------------------

    def role_has_open_id_lock? cls, subject_id
      @role_has_open_id_lock ||= {}
      @role_has_open_id_lock["#{cls}_#{subject_id}"] ||= begin
        inherited_from_relation_ids_locks_for_subject_type(cls).
          select{ |l| l.open?(options) }.
          map(&:subject_id).
          include?(subject_id)
      end
    end

    def owner_has_open_id_lock? cls, subject_id
      @owner_has_open_id_lock ||= {}
      @owner_has_open_id_lock["#{cls}_#{subject_id}"] ||= begin
        owner_id_locks_for_subject_type(cls).
          select{ |l| l.open?(options) }.
          map(&:subject_id).
          include?(subject_id)
      end
    end

    # ---------------------------------------------------------------------

    def criteria_for_class cls
      @criteria_for_class ||= {}
      @criteria_for_class[cls] ||= ability.can?(action, cls, options) ? exclude_criteria(cls) : include_criteria(cls)
    end

    def exclude_criteria cls
      @exclude_criteria ||= {}
      @exclude_criteria[cls] ||= begin
        id_locks = inherited_from_relation_ids_locks_for_subject_type(cls).select{ |l| l.closed?(options) }
        id_locks = id_locks.reject{ |lock| role_has_open_id_lock?(cls, lock.subject_id) }
        id_locks = id_locks.reject{ |lock| owner_has_open_id_lock?(cls, lock.subject_id) }
        id_locks += owner_id_locks_for_subject_type(cls).select{ |l| l.closed?(options) }

        excluded_ids = id_locks.map(&:subject_id).flatten

        conditions = { :_id.nin => excluded_ids }
        conditions = conditions.merge(_type: cls.to_s) if hereditary?

        base_criteria.or(conditions)
      end
    end

    def include_criteria cls
      @include_criteria ||= {}
      @include_criteria[cls] ||= begin
        id_locks = inherited_from_relation_ids_locks_for_subject_type(cls).select{ |l| l.open?(options) }
        id_locks += owner_id_locks_for_subject_type(cls).select{ |l| l.open?(options) }

        included_ids = id_locks.map(&:subject_id).flatten

        conditions = { :_id.in => included_ids }
        conditions = conditions.merge(_type: cls.to_s) if hereditary?

        base_criteria.or(conditions)
      end
    end

  end
end
