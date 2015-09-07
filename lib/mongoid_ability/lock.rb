require 'mongoid'

module MongoidAbility
  module Lock
    def self.included base
      base.extend ClassMethods
      base.class_eval do
        field :action, type: Symbol, default: :read
        field :outcome, type: Boolean, default: false

        belongs_to :subject, polymorphic: true, touch: true

        # TODO: validate that action is defined on subject or its superclasses
        validates :action, presence: true, uniqueness: { scope: [ :subject_type, :subject_id, :outcome ] }
        validates :outcome, presence: true

        scope :for_action, -> action { where(action: action.to_sym) }

        scope :for_subject_type, -> subject_type { where(subject_type: subject_type.to_s) }
        scope :for_subject_id, -> subject_id { where(subject_id: subject_id.presence) }
        scope :for_subject, -> subject { where(subject_type: subject.class.model_name, subject_id: subject.id) }

        scope :class_locks, -> { where(subject_id: nil) }
        scope :id_locks, -> { ne(subject_id: nil) }
      end
    end

    # =====================================================================

    # NOTE: override for more complicated results
    def calculated_outcome options={}
      outcome
    end

    # NOTE: override for more complicated results
    def conditions
      res = { _type: subject_type }
      res = res.merge(_id: subject_id) if subject_id.present?
      res = { '$not' => res } if calculated_outcome == false
      res
    end

    # calculates outcome as if this lock is not present
    def inherited_outcome
      return calculated_outcome unless owner.present?
      cloned_owner = owner.clone
      cloned_owner.locks_relation = cloned_owner.locks_relation - [self]
      MongoidAbility::Ability.new(cloned_owner).can? action, (subject.present? ? subject : subject_class)
    end

    # ---------------------------------------------------------------------

    def subject_class
      subject_type.constantize
    end

    def open? options={}
      calculated_outcome(options) == true
    end

    def closed? options={}
      !open?(options)
    end

    def class_lock?
      !id_lock?
    end

    def id_lock?
      subject_id.present?
    end
  end
end
