module MongoidAbility
  # adds scope-like methods on top of an Array containing locks

  class LocksDecorator < SimpleDelegator
    def for_action(action)
      select do |lock|
        lock.action == action.to_sym
      end
    end

    def for_subject_type(subject_type)
      select do |lock|
        lock.subject_type == subject_type.to_s
      end
    end

    def for_subject_types(subject_types)
      subject_types = Array(subject_types).map(&:to_s)
      select do |lock|
        subject_types.include?(lock.subject_type)
      end
    end

    def for_subject_id(subject_id)
      select do |lock|
        lock.subject_id == BSON::ObjectId.from_string(subject_id)
      end
    end

    def for_subject(subject)
      select do |lock|
        lock.subject_type == subject.class.model_name &&
          lock.subject_id == subject.id
      end
    end

    def class_locks
      compact.select(&:class_lock?)
    end

    def id_locks
      compact.select(&:id_lock?)
    end
  end
end
