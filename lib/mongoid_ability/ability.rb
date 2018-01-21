require 'cancancan'

module MongoidAbility
  class Ability
    include CanCan::Ability

    attr_accessor :owner

    def marshal_dump
      @rules
    end

    def marshal_load(array)
      Array(array).each do |rule|
        add_rule(rule)
      end
    end

    def self.subject_classes
      Object.descendants.select do |cls|
        cls.included_modules.include?(MongoidAbility::Subject)
      end
    end

    def self.subject_root_classes
      subject_classes.reject do |cls|
        cls.superclass.included_modules.include?(MongoidAbility::Subject)
      end
    end

    def initialize(owner)
      @owner = owner

      inherited_locks = owner.respond_to?(owner.class.inherit_from_relation_name) ? owner.inherit_from_relation.flat_map(&:locks_relation) : []
      inherited_locks = LocksDecorator.new(inherited_locks)

      owner_locks = owner.respond_to?(owner.class.locks_relation_name) ? owner.locks_relation : []

      self.class.subject_root_classes.each do |cls|
        cls_list = [cls] + cls.descendants
        cls_list.each do |subcls|
          # if 2 of the same, prefer open
          locks = subcls.default_locks.for_subject_type(subcls).group_by(&:group_key_for_calc).flat_map do |_, locks|
            locks.detect(&:open?) || locks.first
          end

          # if 2 of the same, prefer open
          locks += inherited_locks.for_subject_type(subcls).group_by(&:group_key_for_calc).flat_map do |_, locks|
            locks.detect(&:open?) || locks.first
          end

          # if 2 of the same, prefer open
          locks += owner_locks.for_subject_type(subcls).group_by(&:group_key_for_calc).flat_map do |_, locks|
            locks.detect(&:open?) || locks.first
          end

          selected_locks = locks.group_by(&:group_key_for_calc).flat_map do |_, locks|
            # prefer last one, i.e. the one closest to owner
            locks.last
          end

          selected_locks.sort(&Lock.sort).each do |lock|
            apply_lock_rule(lock)
          end
        end
      end
    end

    def model_adapter(model_class, action, options = {})
      adapter_class = CanCan::ModelAdapters::AbstractAdapter.adapter_class(model_class)
      # include all rules that apply for descendants as well
      # so the adapter can exclude include subclasses from critieria
      rules = ([model_class] + model_class.descendants).inject([]) do |res, cls|
        res += relevant_rules_for_query(action, cls)
        res.uniq
      end
      adapter_class.new(model_class, rules, options)
    end

    private

    def apply_lock_rule(lock)
      ability_type = lock.outcome ? :can : :cannot
      cls = lock.subject_class
      options = lock.options
      options = options.merge(id: lock.subject_id) if lock.id_lock?
      action = lock.action
      send ability_type, action, cls, options
    end
  end
end
