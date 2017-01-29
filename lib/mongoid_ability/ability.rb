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
        subject_id = subject ? subject.id : nil
        if lock = ResolveLocks.call(owner, action, subject_type, subject_id, options)
          lock.calculated_outcome(options)
        end
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
