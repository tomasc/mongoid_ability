module MongoidAbility
  class AccessibleQueryBuilder < Struct.new(:base_class, :ability, :action, :options)
    def self.call(*args)
      new(*args).call
    end

    def initialize(base_class, ability, action, options = {})
      super(base_class, ability, action, options)
    end

    # =====================================================================

    def call
      base_class.criteria#.where(conditions)
    end

    def conditions
      { '$and' => [{ '$or' => [closed_types_condition, open_types_and_ids_condition] }, closed_ids_condition] }
    end

    private # =============================================================

    def closed_types_condition
      { type_key => { '$nin' => values.closed_types.uniq } }
    end

    def open_types_and_ids_condition
      {
        type_key => { '$in' => values.open_types_and_ids.map(&:type).uniq },
        id_key => { '$in' => values.open_types_and_ids.map(&:id).uniq }
      }
    end

    def closed_ids_condition
      { id_key => { '$nin' => values.closed_ids.uniq } }
    end

    # ---------------------------------------------------------------------

    def values
      @values ||= base_class.values_for_accessible_query(ability, action, options)
    end

    # ---------------------------------------------------------------------

    def base_class_superclass
      @base_class_superclass ||= (base_class.ancestors_with_default_locks.last || base_class)
    end

    # ---------------------------------------------------------------------

    def prefix
      options.fetch(:prefix, nil)
    end

    def id_key
      [prefix, '_id'].reject(&:blank?).join.to_sym
    end

    def type_key
      [prefix, '_type'].reject(&:blank?).join.to_sym
    end
  end
end
