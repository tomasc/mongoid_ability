require 'mongoid'

module MongoidAbility
  module Lock
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        field :action, type: Symbol, default: :read
        field :outcome, type: Boolean, default: false
        field :options, type: Hash, default: {}

        belongs_to :subject, polymorphic: true, touch: true, optional: true

        # TODO: validate that action is defined on subject or its superclasses
        validates :action, presence: true, uniqueness: { scope: [:subject_type, :subject_id, :outcome] }
        validates :outcome, presence: true

        scope :for_action, -> (action) { where(action: action.to_sym) }

        scope :for_subject_type, -> (subject_type) { where(subject_type: subject_type.to_s) }

        scope :for_subject_id, -> (subject_id) {
          return where(subject_id: nil) unless subject_id.present?
          where(subject_id: BSON::ObjectId.from_string(subject_id))
        }

        scope :for_subject, -> (subject) {
          return where(subject_id: nil) unless subject.present?
          where(subject_type: subject.class.model_name, subject_id: subject.id)
        }

        scope :class_locks, -> { where(subject_id: nil) }
        scope :id_locks, -> { ne(subject_id: nil) }
      end
    end

    # =====================================================================

    concerning :LockType do
      def class_lock?
        !id_lock?
      end

      def id_lock?
        subject_id.present?
      end
    end

    concerning :Outcome do
      # NOTE: override for more complicated results
      def calculated_outcome(_options = {})
        outcome
      end

      def open?(options = {})
        calculated_outcome(options) == true
      end

      def closed?(options = {})
        !open?(options)
      end
    end

    concerning :InheritedOutcome do
      # calculates outcome as if this lock is not present
      def inherited_outcome(options = default_options)
        return calculated_outcome(options) unless owner.present?
        cloned_owner = owner.clone
        cloned_owner.locks_relation = cloned_owner.locks_relation - [self]
        MongoidAbility::Ability.new(cloned_owner).can? action, (subject.present? ? subject : subject_class), options
      end

      # used when calculating inherited outcome
      def default_options
        {}
      end
    end

    concerning :Subject do
      def subject_class
        subject_type.constantize
      end
    end
  end
end
