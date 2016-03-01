module MongoidAbility
  class AccessibleQueryBuilder < Struct.new(:base_class, :ability, :action, :options)
    def self.call(*args)
      new(*args).call
    end

    # =====================================================================

    def call
      return base_class.criteria unless and_conditions.present?
      base_class.criteria.where(conditions)
    end

    def conditions
      and_conditions
    end

    private # =============================================================

    def and_conditions
      return unless conditions = [or_conditions, closed_ids_condition].compact.presence
      { '$and' => conditions }
    end

    def or_conditions
      return unless conditions = [closed_types_condition, open_ids_condition].compact.presence
      { '$or' => conditions }
    end

    def closed_types_condition
      return unless values.closed_types.present?
      { _type: { '$nin' => values.closed_types } }
    end

    def open_ids_condition
      return unless values.open_types_and_ids.present?
      { _id: { '$in' => values.open_types_and_ids.map(&:id) } }
    end

    def closed_ids_condition
      return unless values.closed_ids.present?
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
