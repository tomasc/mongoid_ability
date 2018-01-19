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
        locks.detect(&:closed?) || locks.detect(&:open?)
      end

      private

      def locks
        subject_class.default_locks.for_action(action)
      end
    end
  end
end
