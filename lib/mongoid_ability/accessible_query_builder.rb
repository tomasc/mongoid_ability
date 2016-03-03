module MongoidAbility
  class AccessibleQueryBuilder < Struct.new(:base_class, :ability, :action, :options)
    def self.call(*args)
      new(*args).call
    end

    # =====================================================================

    def call
      base_class.criteria.where(conditions)
    end

    def conditions
      { '$and' => [{ '$or' => [closed_types_condition, open_types_and_ids_condition] }, closed_ids_condition] }
    end

    private # =============================================================

    def closed_types_condition
      { _type: { '$nin' => values.closed_types } }
    end

    def open_types_and_ids_condition
      {
        _type: { '$in' => values.open_types_and_ids.map(&:type) },
        _id: { '$in' => values.open_types_and_ids.map(&:id) }
      }
    end

    def closed_ids_condition
      { _id: { '$nin' => values.closed_ids } }
    end

    # ---------------------------------------------------------------------

    def values
      @values ||= base_class.values_for_accessible_query(ability, action, options)
    end

    # ---------------------------------------------------------------------

    def base_class_superclass
      @base_class_superclass ||= (base_class.ancestors_with_default_locks.last || base_class)
    end

    def default_lock(_cls, action)
      base_class_superclass.default_locks.detect { |l| l.action.to_s == action.to_s }
    end
  end
end
