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
        Object.descendants.detect{ |cls| cls < MongoidAbility::Lock }.name
      end

      # ---------------------------------------------------------------------

      def self_and_ancestors_with_default_locks
        self.ancestors.select{ |a| a.is_a?(Class) && a.respond_to?(:default_locks) }
      end

      def ancestors_with_default_locks
        self_and_ancestors_with_default_locks - [self]
      end

      # ---------------------------------------------------------------------

      # TODO: obviously this could be cleaner
      def accessible_by ability, action=:read
        cr = self.criteria

        return cr unless ability.user.present?

        supercls = self.ancestors_with_default_locks.last || self
        subject_classes = [supercls].concat(supercls.descendants)

        subject_classes.each do |cls|

          roles_id_locks = ability.user.roles_relation.collect{ |role| role.locks_relation.for_subject_type(cls.to_s).id_locks.for_action(action) }.flatten
          user_id_locks = ability.user.locks_relation.for_subject_type(cls.to_s).id_locks.for_action(action)

          closed_roles_id_locks = roles_id_locks.to_a.select(&:closed?)
          open_roles_id_locks = roles_id_locks.to_a.select(&:open?)

          closed_user_id_locks = user_id_locks.to_a.select(&:closed?)
          open_user_id_locks = user_id_locks.to_a.select(&:open?)

          if ability.can?(action, cls)
            excluded_ids = []

            id_locks = closed_roles_id_locks.
              reject{ |cl| open_roles_id_locks.any?{ |ol| ol.subject_id == cl.subject_id } }.
              reject{ |cl| open_user_id_locks.any?{ |ol| ol.subject_id == cl.subject_id } }

            id_locks += closed_user_id_locks
            
            excluded_ids << id_locks.map(&:subject_id)

            cr = cr.or(_type: cls.to_s, :_id.nin => excluded_ids.flatten)
          else
            included_ids = []

            id_locks = open_roles_id_locks
            id_locks += open_user_id_locks

            included_ids << id_locks.map(&:subject_id)

            cr = cr.or(_type: cls.to_s, :_id.in => included_ids.flatten)
          end
        end

        cr
      end
    end

  end
end
