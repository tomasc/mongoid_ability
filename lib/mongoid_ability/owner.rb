module MongoidAbility
  module Owner

    def self.included base
      base.extend ClassMethods
      base.class_eval do
        before_save :cleanup_locks
      end
    end

    # =====================================================================

    module ClassMethods
      # override if needed
      # return for example :my_locks
      def locks_relation_name
        @locks_relation_name ||= relations.detect{ |name, meta| meta.class_name == lock_class_name }.first.to_sym
      end

      # override if your relation is named differently
      def roles_relation_name
        :roles
      end

      # override if needed
      # return for example 'MyLock'
      def lock_class_name
        @lock_class_name ||= Object.subclasses.detect{ |cls| cls < MongoidAbility::Lock }.name
      end
    end

    # =====================================================================
    
    def locks_relation
      self.send(self.class.locks_relation_name)
    end

    def roles_relation
      self.send(self.class.roles_relation_name)
    end

    private # =============================================================

    def cleanup_locks
      locks_relation.select(&:open?).each do |lock|
        lock.destroy if locks_relation.where(action: lock.action, subject_type: lock.subject_type, subject_id: lock.subject_id).any?(&:closed?)
      end
    end

  end
end
