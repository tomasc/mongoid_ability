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

      # locks on owner
      # locks on owner roles
      #   • sorted by class going up
      # locks on classes up

      owner.locks.each { |lock| process_lock(lock) }

      owner.inherit_from_relation.each do |inherited|
        inherited.locks.each { |lock| process_lock(lock) }
      end

      self.class.subject_root_classes.each do |cls|
        ([cls] + cls.descendants).reverse.each do |subcls|
          subcls.default_locks.each { |lock| process_lock(lock) }
        end
      end
    end

    def process_lock(lock)
      ability = lock.outcome ? :can : :cannot
      self.send(ability, lock.action, lock.subject_class)
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
  end
end
