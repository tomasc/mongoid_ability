module MongoidAbility
  module Subject

    def self.included base
      base.extend ClassMethods
      base.class_eval do
      end
    end

    # ---------------------------------------------------------------------

    module ClassMethods
      def default_locks
        @default_locks ||= []
      end

      def default_locks= locks
        @default_locks = locks
      end

      def default_lock lock_cls, action, outcome, attrs={}
        lock = lock_cls.new( { subject_type: self.to_s, action: action, outcome: outcome }.merge(attrs))

        if existing_lock = default_locks.detect{ |l| l.action.to_s == lock.action.to_s }
          default_locks.delete(existing_lock)
        end

        default_locks.push lock
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

  end
end
