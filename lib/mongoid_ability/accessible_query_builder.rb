module MongoidAbility
  class AccessibleQueryBuilder < Struct.new(:base_class, :ability, :action, :options)
    def self.call(*args)
      new(*args).call
    end

    # =====================================================================

    # TODO: cleanup
    def call
      closed_classes = [] # [cls]
      open_ids = [] # [cls, id]
      closed_ids = [] # [id]

      base_class_and_descendants.each do |cls|
        closed_classes << cls if ability.cannot?(action, cls, options)
        
        id_locks(cls).each do |lock|
          if ability.can?(action, cls.new(_id: lock.subject_id), options)
            open_ids << [cls, lock.subject_id]
          else
            closed_ids << lock.subject_id
          end
        end
      end

      closed_classes_condition = { :_type.nin => closed_classes }
      open_ids_condition = { :_type.in => open_ids.map(&:first), :_id.in => open_ids.map(&:last) }
      closed_ids_condition = { :_id.nin => closed_ids }
      or_conditions = [ closed_classes_condition, open_ids_condition ].reject(&:blank?)

      base_criteria.where( :$and => [ { :$or => or_conditions }, closed_ids_condition ])
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
