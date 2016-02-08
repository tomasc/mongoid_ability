module MongoidAbility
  class ValuesForAccessibleQuery < Struct.new(:base_class, :ability, :action, :options)
    def self.call(*args)
      new(*args).call
    end

    # =====================================================================

    def call
      closed_types = [] # [cls]
      open_types_and_ids = [] # OpenStruct.new(type: …, id: …)
      closed_ids = [] # [id]

      base_class_and_descendants.each do |cls|
        closed_types << cls.to_s if ability.cannot?(action, cls, options)
        id_locks(cls).each do |lock|
          if ability.can?(action, cls.new(_id: lock.subject_id), options)
            open_types_and_ids << OpenStruct.new(type: cls.to_s, id: lock.subject_id)
          else
            closed_ids << lock.subject_id
          end
        end
      end

      OpenStruct.new(
        closed_types: closed_types,
        open_types_and_ids: open_types_and_ids,
        closed_ids: closed_ids
      )
    end

    private # =============================================================

    def base_class_and_descendants
      @base_class_and_descendants ||= [base_class].concat(base_class.descendants)
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

    # ---------------------------------------------------------------------

    def owner
      @owner ||= ability.owner
    end

    # ---------------------------------------------------------------------

    def inherited_from_relation
      return unless owner.respond_to?(owner.class.inherit_from_relation_name)
      owner.inherit_from_relation
    end
  end
end
