module MongoidAbility
  # finds first lock that controls specified params

  class FindLock < Struct.new(:owner, :action, :subject_type, :subject_id, :options)
    def self.call(*args)
      new(*args).call
    end

    def initialize(owner, action, subject_type, subject_id = nil, options = {})
      super(owner, action, subject_type.to_s, subject_id, options)
    end

    def call
      lock = nil
      subject_class.self_and_ancestors_with_default_locks.each do |cls|
        break if lock = FindOwnedLock.call(owner, action, cls, subject_id, options)
        break if lock = FindInheritedLock.call(owner, action, cls, subject_id, options)
        break if lock = FindDefaultLock.call(owner, action, cls, subject_id, options)
      end
      lock
    end

    private

    def subject_class
      subject_type.constantize
    end

    # ---------------------------------------------------------------------

    class FindDefaultLock < FindLock
      def call
        locks = subject_class.default_locks.for_action(action)
        locks.compact.detect(&:closed?) || locks.compact.detect(&:open?)
      end
    end

    class FindInheritedLock < FindLock
      def call
        return unless owner.respond_to?(owner.class.inherit_from_relation_name)
        locks = LocksDecorator.new(
          owner.inherit_from_relation
                .flat_map { |inherited_owner| FindOwnedLock.call(inherited_owner, action, subject_type, subject_id, options) }
        )

        if subject_id.present?
          lock = locks.for_subject_id(subject_id).detect(&:closed?) ||
                 locks.for_subject_id(subject_id).detect(&:open?)
          return lock unless lock.nil?
        end

        locks.class_locks.detect(&:open?) || locks.class_locks.detect(&:closed?)
      end
    end

    class FindOwnedLock < FindLock
      def call
        return unless owner.respond_to?(:locks_relation)
        locks = owner.locks_relation.for_action(action).for_subject_type(subject_type)

        if subject_id.present?
          lock = locks.for_subject_id(subject_id).detect(&:closed?) ||
                 locks.for_subject_id(subject_id).detect(&:open?)
          return lock unless lock.nil?
        end

        locks.class_locks.detect(&:closed?) || locks.class_locks.detect(&:open?)
      end
    end
  end
end
