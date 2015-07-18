require 'cancancan'

module MongoidAbility
  class Ability
    include CanCan::Ability

    attr_reader :owner

    def initialize owner
      @owner = owner

      can do |action, subject_type, subject, options|
        subject_class = subject_type.to_s.constantize
        outcome = nil
        options ||= {}

        subject_class.self_and_ancestors_with_default_locks.each do |cls|
          outcome = ResolveInheritedLocks.call(owner, action, cls, subject, options)
          break if outcome != nil
        end

        outcome
      end
    end

  end
end
