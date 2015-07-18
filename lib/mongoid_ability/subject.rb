module MongoidAbility
  module Subject

    def self.included base
      base.extend ClassMethods
    end

    # ---------------------------------------------------------------------

    module ClassMethods
      def default_locks
        @default_locks ||= DefaultLocksExtension.new
      end

      def default_locks= locks
        @default_locks = DefaultLocksExtension.new(locks)
      end

      # TODO: apply to subclasses?
      def default_lock lock_cls, action, outcome
        default_locks << lock_cls.new(subject_type: self.to_s, action: action, outcome: outcome)
        # subclasses.each { |cls| cls.default_lock lock_cls, action, outcome }
      end

      def self_and_ancestors_with_default_locks
        ancestors.select { |a| a.is_a?(Class) && a.respond_to?(:default_locks) }
      end

      def ancestors_with_default_locks
        self_and_ancestors_with_default_locks - [self]
      end

      def accessible_by ability, action=:read, options={}
        AccessibleQueryBuilder.call(self, ability, action, options)
      end
    end

    # ---------------------------------------------------------------------

    require 'forwardable'
    class DefaultLocksExtension
      extend Forwardable
      def_delegators :@default_locks, :any?, :delete, :detect, :first, :map, :push, :select

      attr_reader :default_locks

      def initialize default_locks=[]
        @default_locks = default_locks
      end

      def for_action action
        DefaultLocksExtension.new(
          @default_locks.select { |l| l.action.to_s == action.to_s }
        )
      end

      def << lock
        if existing_lock = self.for_action(lock.action).first
          @default_locks.delete(existing_lock)
        end
        @default_locks.push lock
      end
    end

  end
end





# GRAVEYARD

#       def default_locks_with_inherited
#         return default_locks unless superclass.respond_to?(:default_locks_with_inherited)
#         superclass.default_locks_with_inherited.concat(default_locks)
#       end
