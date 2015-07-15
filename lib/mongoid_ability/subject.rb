module MongoidAbility
  module Subject
    def self.included base
      base.extend ClassMethods
      base.class_eval do
        attr_reader :default_locks
      end
    end

    module ClassMethods
      def default_locks
        @default_locks ||= []
      end

      def default_lock lock_cls, action, outcome
        default_locks << lock_cls.new(subject_type: self, action: action, outcome: outcome)
        subclasses.each { |cls| cls.default_lock lock_cls, action, outcome }
      end

      def self_and_ancestors_with_default_locks
        ancestors.select { |a| a.is_a?(Class) && a.respond_to?(:default_locks) }
      end

      # def accessible_by ability, action=:read
      #   AccessibleQueryBuilder.call(self, ability, action)
      # end
    end
  end
end














# module MongoidAbility
#   module Subject
#
#     def self.included base
#       base.extend ClassMethods
#       base.class_eval do
#       end
#     end
#
#     # =====================================================================
#
#     module ClassMethods
#       def default_locks
#         @default_locks ||= []
#       end
#
#       def default_locks_with_inherited
#         return default_locks unless superclass.respond_to?(:default_locks_with_inherited)
#         superclass.default_locks_with_inherited.concat(default_locks)
#       end
#
#       def default_locks= val
#         @default_locks = val
#       end
#
#       def default_lock action, outcome
#         if existing_lock = default_locks.detect{ |l| l.action.to_s == action.to_s }
#           existing_lock.outcome = outcome
#         else
#           default_locks << lock_class_name.constantize.new(subject_type: self, action: action, outcome: outcome)
#         end
#       end
#
#       # ---------------------------------------------------------------------
#
#       # override if needed
#       # return for example 'MyLock'
#       def lock_class_name
#         lock_classes = ObjectSpace.each_object(Class).select{ |cls| cls < MongoidAbility::Lock }
#         lock_superclasses = lock_classes.reject{ |cls| lock_classes.any?{ |c| cls < c } }
#         @lock_class_name ||= lock_superclasses.first.name
#       end
#
#       # ---------------------------------------------------------------------
#
#       def self_and_ancestors_with_default_locks
#         self.ancestors.select{ |a| a.is_a?(Class) && a.respond_to?(:default_locks) }
#       end
#
#       def ancestors_with_default_locks
#         self_and_ancestors_with_default_locks - [self]
#       end
#
#       # ---------------------------------------------------------------------
#
#       def accessible_by ability, action=:read
#         AccessibleQueryBuilder.call(self, ability, action)
#       end
#     end
#
#   end
# end
