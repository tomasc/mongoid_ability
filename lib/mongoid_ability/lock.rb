# frozen_string_literal: true

require 'mongoid'

module MongoidAbility
  module Lock
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        field :action, type: Symbol, default: :read
        field :outcome, type: Boolean, default: false
        field :opts, as: :options, type: Hash, default: {}

        belongs_to :subject, polymorphic: true, optional: true
        # Mongoid 7 does not support `touch: true` on polymorphic associations
        after_save -> { subject.touch if subject? }
        after_destroy -> { subject.touch if subject? }
        after_touch -> { subject.touch if subject? }

        # TODO: validate that action is defined on subject or its superclasses
        validates :action, presence: true, uniqueness: { scope: [:subject_type, :subject_id, :outcome] }
        validates :outcome, presence: true

        scope :for_action, ->(action) { where(action: action.to_sym) }

        scope :for_subject_type, ->(subject_type) { where(subject_type: subject_type.to_s) }
        scope :for_subject_types, ->(subject_types) { criteria.in(subject_type: subject_types) }

        scope :for_subject_id, ->(subject_id) {
          return where(subject_id: nil) unless subject_id.present?
          where(subject_id: BSON::ObjectId.from_string(subject_id))
        }

        scope :for_subject, ->(subject) {
          return where(subject_id: nil) unless subject.present?
          where(subject_type: subject.class.model_name, subject_id: subject.id)
        }

        scope :class_locks, -> { where(subject_id: nil) }
        scope :id_locks, -> { ne(subject_id: nil) }
      end
    end

    concerning :LockType do
      def class_lock?
        !id_lock?
      end

      def id_lock?
        subject_id.present?
      end
    end

    concerning :Outcome do
      def open?
        outcome
      end

      def closed?
        !open?
      end
    end

    # calculates outcome as if this lock is not present
    concerning :InheritedOutcome do
      def inherited_outcome(options = {})
        return outcome unless owner.present?
        cloned_owner = owner.clone
        cloned_owner.locks_relation = cloned_owner.locks_relation - [self]
        cloned_ability = MongoidAbility::Ability.new(cloned_owner)

        cloned_ability.can?(action, (subject.present? ? subject : subject_class), options)
      end
    end

    concerning :Subject do
      def subject_class
        subject_type.constantize
      end
    end

    concerning :Group do
      def group_key_for_calc
        [subject_type, subject_id, action, options]
      end
    end

    concerning :Sort do
      class_methods do
        def sort
          -> (a, b) {
            [a.subject_type, a.subject_id.to_s, a.action, (a.outcome ? -1 : 1)] <=>
              [b.subject_type, b.subject_id.to_s, b.action, (b.outcome ? -1 : 1)]
          }
        end
      end
    end
  end
end
