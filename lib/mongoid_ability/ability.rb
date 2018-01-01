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

      self.class.subject_root_classes.each do |cls|
        cls_list = [cls] + cls.descendants
        cls_list.each do |subcls|
          grouped_locks = subcls.default_locks.group_by(&:group_key)
          selected_locks = grouped_locks.flat_map do |_, locks|
            locks.detect(&:open?) || locks.first # prefer positive outcome
          end
          selected_locks.sort.each do |lock|
            apply_lock_rule(lock)
          end
        end
      end

      if owner.respond_to?(owner.class.inherit_from_relation_name)
        combined_locks = owner.inherit_from_relation.flat_map(&:locks_relation)
        grouped_locks = combined_locks.group_by(&:group_key)
        selected_locks = grouped_locks.flat_map do |_, locks|
          locks.detect(&:open?) || locks.first # prefer positive outcome
        end
        selected_locks.sort.each do |lock|
          apply_lock_rule(lock)
        end
      end

      return unless owner.respond_to?(owner.class.locks_relation_name)
      return unless owner.locks_relation.present?
      grouped_locks = owner.locks_relation.group_by(&:group_key)
      selected_locks = grouped_locks.flat_map do |_, locks|
        locks.detect(&:open?) || locks.first # prefer positive outcome
      end
      selected_locks.sort.each do |lock|
        apply_lock_rule(lock)
      end
    end

    # lambda for easy permission checking:
    # .select(&current_ability.can_read)
    # .select(&current_ability.can_update)
    # .select(&current_ability.can_destroy)
    # etc.
    def method_missing(name, *args)
      return super unless name.to_s =~ /\A(can|cannot)_/
      return unless action = name.to_s.scan(/\A(can|cannot)_(\w+)/).flatten.last.to_sym

      if args.empty? || args.first.is_a?(Hash)
        case name
        when /can_/ then -> (doc) { can?(action, doc, *args) }
        else -> (doc) { cannot?(action, doc, *args) }
        end
      else
        case name
        when /can_/ then can?(action, *args)
        else cannot?(action, *args)
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

      self.send ability_type, action, cls, options
    end
  end
end
