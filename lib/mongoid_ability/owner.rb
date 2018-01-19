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
      return unless respond_to?(self.class.locks_relation_name)
      send(self.class.locks_relation_name)
    end

    def locks_relation=(val)
      return unless respond_to?("#{self.class.locks_relation_name}=")
      send "#{self.class.locks_relation_name}=", val
    end

    def inherit_from_relation
      return unless respond_to?(self.class.inherit_from_relation_name)
      send(self.class.inherit_from_relation_name)
    end

    def ability
      @ability ||= MongoidAbility::Ability.new(self)
    end

    def has_lock?(lock)
      @has_lock ||= {}

      return @has_lock[lock.id.to_s] if @has_lock.key?(lock.id.to_s)

      @has_lock[lock.id.to_s] ||= begin
        locks_relation.where(
          subject_type: lock.subject_type,
          subject_id: lock.subject_id.presence,
          action: lock.action,
          options: lock.options
        ).exists?
      end
    end

    private

    def cleanup_locks
      locks_relation.select(&:open?).each do |lock|
        lock.destroy if locks_relation.where(
          subject_type: lock.subject_type,
          subject_id: lock.subject_id.presence,
          action: lock.action,
          options: lock.options
        ).any?(&:closed?)
      end
    end
  end
end
