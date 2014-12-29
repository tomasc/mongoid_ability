module MongoidAbility
  module Owner

    def self.included base
      base.extend ClassMethods
      base.class_eval do
        embeds_many :locks, class_name: lock_class_name, as: :owner
        before_save :cleanup_locks
      end
    end

    # =====================================================================

    module ClassMethods
      def roles_relation_name
        :roles
      end

      def lock_class_name
        Object.subclasses.detect{ |cls| cls < MongoidAbility::Lock }.name
      end
    end

    # =====================================================================
    
    def roles_relation
      self.send(self.class.roles_relation_name)
    end

    private # =============================================================

    def cleanup_locks
      locks.select(&:open?).each do |lock|
        lock.destroy if locks.where(action: lock.action, subject_type: lock.subject_type, subject_id: lock.subject_id).any?(&:closed?)
      end
    end

  end
end
