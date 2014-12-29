module MongoidAbility
  module Subject

    def self.included base
      base.extend ClassMethods
      base.class_eval do
      end
    end

    # =====================================================================

    module ClassMethods
      def default_locks
        @default_locks ||= []
      end

      def default_locks= val
        @default_locks = val
      end

      def default_lock action, outcome
        default_locks << lock_class_name.constantize.new(subject_type: self, action: action, outcome: outcome)
      end

      # ---------------------------------------------------------------------
      
      # override if needed
      # return for example 'MyLock'
      def lock_class_name
        Object.subclasses.detect{ |cls| cls < MongoidAbility::Lock }.name
      end

      # ---------------------------------------------------------------------
        
      def self_and_ancestors_with_default_locks
        self.ancestors.select{ |a| a.is_a?(Class) && a.respond_to?(:default_locks) }
      end

      def ancestors_with_default_locks
        self_and_ancestors_with_default_locks - [self]
      end

      # ---------------------------------------------------------------------
        
      def accessible_by ability, action=:read
        criteria = Mongoid::Criteria.new(self)

        return criteria unless ability.user.present?

        id_locks = [
          ability.user,
          ability.user.roles_relation
        ].flatten.collect { |owner|
          owner.locks_relation.for_subject_type(self.to_s).id_locks.for_action(action).to_a
        }.flatten

        if ability.can?(action, self)
          criteria.nin({
                         _id: id_locks.map(&:subject_id).select do |subject_id|
                           subject = self.new
                           subject.id = subject_id
                           ability.cannot?(action, subject)
                         end
          })
        else
          criteria.in({
                        _id: id_locks.map(&:subject_id).select do |subject_id|
                          subject = self.new
                          subject.id = subject_id
                          ability.can?(action, subject)
                        end
          })
        end
      end
    end

    # =====================================================================

  end
end
