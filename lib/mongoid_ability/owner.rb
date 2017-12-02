module MongoidAbility
  module Owner
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        delegate :can?, :cannot?, to: :ability
        before_save :cleanup_locks
      end
    end

    module ClassMethods
      def locks_relation_name
        :locks
      end

      def inherit_from_relation_name
        :roles
      end
    end

    def locks_relation
      send(self.class.locks_relation_name)
    end

    def locks_relation=(val)
      send "#{self.class.locks_relation_name}=", val
    end

    def inherit_from_relation
      send(self.class.inherit_from_relation_name)
    end

    def ability
      @ability ||= MongoidAbility::Ability.new(self)
    end

    def has_lock?(lock)
      @has_lock ||= {}
      @has_lock[lock.id.to_s] ||= locks_relation.where(action: lock.action, subject_type: lock.subject_type, subject_id: lock.subject_id.presence).cache.exists?
    end

    private

    def cleanup_locks
      locks_relation.select(&:open?).each do |lock|
        lock.destroy if locks_relation.where(action: lock.action, subject_type: lock.subject_type, subject_id: lock.subject_id).any?(&:closed?)
      end
    end
  end
end
