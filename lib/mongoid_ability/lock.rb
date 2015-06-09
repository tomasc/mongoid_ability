module MongoidAbility
  module Lock

    def self.included base
      base.extend ClassMethods
      base.class_eval do
        field :action, type: Symbol, default: :read
        field :outcome, type: Boolean, default: false

        # ---------------------------------------------------------------------
        
        belongs_to :subject, polymorphic: true, touch: true

        # ---------------------------------------------------------------------
          
        validates :action, presence: true, uniqueness: { scope: [ :subject_type, :subject_id, :outcome ] }
        validates :outcome, presence: true

        # ---------------------------------------------------------------------
          
        scope :for_action, -> action { where(action: action.to_sym) }

        scope :for_subject_type, -> subject_type { where(subject_type: subject_type.to_s) }
        scope :for_subject_id, -> subject_id { where(subject_id: subject_id) }
        scope :for_subject, -> subject { where(subject_type: subject.class.model_name, subject_id: subject.id) }

        scope :class_locks, -> { where(subject_id: nil) }
        scope :id_locks, -> { ne(subject_id: nil) }
      end
    end

    # =====================================================================
      
    module ClassMethods
    end

    # =====================================================================
    
    def calculated_outcome
      self.outcome
    end

    # ---------------------------------------------------------------------
    
    def open?
      self.calculated_outcome == true
    end

    def closed?
      !open?
    end

    # ---------------------------------------------------------------------
      
    def class_lock?
      !id_lock?
    end

    def id_lock?
      self.subject_id.present?
    end

    # ---------------------------------------------------------------------
    
    def conditions
      res = { _type: subject_type }
      res = res.merge(_id: subject_id) if subject_id.present?
      res = { '$not' => res } if calculated_outcome == false
      res
    end

  end
end
