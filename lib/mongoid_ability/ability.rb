require 'cancancan'

module MongoidAbility
  class Ability
    include CanCan::Ability

    attr_reader :owner

    def self.subject_classes
      Object.descendants.select { |cls| cls.included_modules.include?(MongoidAbility::Subject) }
    end

    def self.subject_root_classes
      subject_classes.reject { |cls| cls.superclass.included_modules.include?(MongoidAbility::Subject) }
    end

    def initialize(owner)
      @owner = owner

      can do |action, subject_type, subject, options = {}|
        subject_class = subject_type.to_s.constantize
        lock = nil

        subject_class.self_and_ancestors_with_default_locks.each do |cls|
          lock = ResolveInheritedLocks.call(owner, action, cls, subject, options)
          break unless lock.nil?
        end

        lock.calculated_outcome(options) if lock
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

      case name
      when /can_/ then can?(action, *args)
      else cannot?(action, *args)
      end
    end
  end
end
