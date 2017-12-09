module MongoidAbility
  module Subject
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
      end
    end

    module ClassMethods
      def default_locks
        @default_locks ||= []
      end

      def default_locks=(locks)
        @default_locks = locks
      end

      def default_lock(lock_cls, action, outcome, options = {})
        lock = lock_cls.new(subject_type: to_s, action: action, outcome: outcome, options: options)

        # remove any existing locks
        if existing_lock = default_locks.detect { |l| l.action == lock.action && l.options == lock.options }
          default_locks.delete(existing_lock)
        end

        # add new lock
        default_locks.push lock
      end

      # ---------------------------------------------------------------------

      def self_and_ancestors_with_default_locks
        ancestors.select { |a| a.is_a?(Class) && a.respond_to?(:default_locks) }
      end

      def ancestors_with_default_locks
        self_and_ancestors_with_default_locks - [self]
      end

      def is_root_class?
        root_class == self
      end

      def root_class
        self_and_ancestors_with_default_locks.last
      end

      # ---------------------------------------------------------------------

      def default_lock_for_action(action)
        default_locks.detect { |lock| lock.action == action.to_sym }
      end

      def has_default_lock_for_action?(action)
        default_lock_for_action(action).present?
      end

      # ---------------------------------------------------------------------

      def accessible_by(ability, action = :read, options = {})
        AccessibleQueryBuilder.call(self, ability, action, options)
      end

      def values_for_accessible_query(ability, action = :read, options = {})
        ValuesForAccessibleQuery.call(self, ability, action, options)
      end
    end
  end
end
