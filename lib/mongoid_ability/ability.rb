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
      Object.descendants.select { |cls| cls.included_modules.include?(MongoidAbility::Subject) }
    end

    def self.subject_root_classes
      subject_classes.reject { |cls| cls.superclass.included_modules.include?(MongoidAbility::Subject) }
    end

    def initialize(owner)
      @owner = owner

      self.class.subject_root_classes.each do |cls|
        ([cls] + cls.descendants).each do |subcls|
          grouped_locks = subcls.default_locks.group_by(&:group_key)
          grouped_locks.each do |_, locks|
            apply_lock_rule(locks.detect(&:open?) || locks.first) # prefer positive outcome
          end
        end
      end

      if owner.inherit_from_relation
        combined_locks = owner.inherit_from_relation.flat_map(&:locks_relation)
        grouped_locks = combined_locks.group_by(&:group_key)
        grouped_locks.each do |_, locks|
          apply_lock_rule(locks.detect(&:open?) || locks.first) # prefer positive outcome
        end
      end

      return unless owner.locks_relation
      grouped_locks = owner.locks_relation.group_by(&:group_key)
      grouped_locks.each do |_, locks|
        apply_lock_rule(locks.detect(&:open?) || locks.first) # prefer positive outcome
      end
    end

    private

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

    def apply_lock_rule(lock)
      ability_type = lock.outcome ? :can : :cannot
      cls = lock.subject_class
      conditions = lock.class_lock? ? {} : { id: lock.subject_id }
      action = lock.action

      # p "#{ability_type}, #{action}, #{cls}"
      self.send ability_type, action, cls, conditions
    end
  end
end
