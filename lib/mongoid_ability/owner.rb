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
      def lock_class_name
        Object.subclasses.detect{ |cls| cls < MongoidAbility::Lock }.name
      end
    end

    private # =============================================================

    def cleanup_locks
      locks.open.each do |lock|
        lock.destroy if locks.where(action: lock.action, subject_type: lock.subject_type, subject_id: lock.subject_id).closed.exists?
      end
    end

  end
end
