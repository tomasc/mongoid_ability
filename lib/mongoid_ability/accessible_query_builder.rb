module MongoidAbility
  class AccessibleQueryBuilder < Struct.new(:base_class, :ability, :action, :options)
    def self.call(*args)
      new(*args).call
    end

    # =====================================================================

    def call
      base_class_and_descendants.inject(base_criteria) do |criteria, cls|
        conditions = []
        if ability.cannot?(action, cls)
          lock = default_lock(cls, action).dup.tap do |lock|
            lock.subject_type = cls
            lock.outcome = false
          end
          conditions << lock.conditions
        end

        id_locks(cls).each do |lock|
          lock = lock.dup
          lock.subject_type = cls
          lock.outcome = ability.can?(action, cls.new(_id: lock.subject_id))
          conditions << lock.conditions
        end

        if conditions.present? then criteria.merge!(criteria.and(:$or => conditions))
        else criteria
        end
      end
    end

    private # =============================================================

    def base_criteria
      @base_criteria ||= base_class.criteria
    end

    # ---------------------------------------------------------------------

    def base_class_superclass
      @base_class_superclass ||= (base_class.ancestors_with_default_locks.last || base_class)
    end

    def default_lock(_cls, action)
      base_class_superclass.default_locks.detect { |l| l.action.to_s == action.to_s }
    end

    def base_class_and_descendants
      @base_class_and_descendants ||= [base_class].concat(base_class.descendants)
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

    def id_locks(cls)
      (Array(owner_id_locks_for_subject_type(cls)) + Array(inherited_from_relation_ids_locks_for_subject_type(cls))).flatten
    end

    def owner_id_locks_for_subject_type(cls)
      @owner_id_locks_for_subject_type ||= {}
      @owner_id_locks_for_subject_type[cls] ||= owner.locks_relation.id_locks.for_action(action).for_subject_type(cls.to_s)
    end

    def inherited_from_relation_ids_locks_for_subject_type(cls)
      return [] unless inherited_from_relation
      @inherited_from_relation_ids_locks_for_subject_type ||= {}
      @inherited_from_relation_ids_locks_for_subject_type[cls] ||= inherited_from_relation.collect do |o|
        o.locks_relation.id_locks.for_action(action).for_subject_type(cls.to_s)
      end.flatten
    end
  end
end
