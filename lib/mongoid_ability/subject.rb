module MongoidAbility
  module Subject
    def self.included base
      base.extend ClassMethods
      base.class_eval do
        attr_reader :default_locks

        def default_locks.<< lock
          if existing_lock = self.detect{ |l| l.action == lock.action }
            self.push lock
            self.delete(existing_lock)
          else
            self.push lock
          end
        end

      end
    end

    module ClassMethods
      def default_locks
        @default_locks ||= []
      end

      # TODO: apply to subclasses?
      def default_lock lock_cls, action, outcome
        default_locks << lock_cls.new(subject_type: self, action: action, outcome: outcome)
        # subclasses.each { |cls| cls.default_lock lock_cls, action, outcome }
      end

      def self_and_ancestors_with_default_locks
        ancestors.select { |a| a.is_a?(Class) && a.respond_to?(:default_locks) }
      end

      def accessible_by ability, action=:read
        AccessibleQueryBuilder.call(self, ability, action)
      end
    end
  end
end





# GRAVEYARD

#       def default_locks_with_inherited
#         return default_locks unless superclass.respond_to?(:default_locks_with_inherited)
#         superclass.default_locks_with_inherited.concat(default_locks)
#       end
#
#       def ancestors_with_default_locks
#         self_and_ancestors_with_default_locks - [self]
#       end
