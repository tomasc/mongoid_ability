require 'cancancan'
  
module MongoidAbility
  class Ability

    include CanCan::Ability
    
    attr_reader :user

    # =====================================================================

    def initialize user
      @user = user
      
      can do |action, subject_type, subject|
        subject_class = subject_type.to_s.constantize
        outcome = nil

        subject_class.self_and_ancestors_with_default_locks.each do |cls|
          outcome = combined_outcome(user, action, cls, subject)
          break unless outcome.nil?
        end

        outcome
      end
    end

    private # =============================================================
    
    def combined_outcome  user, action, cls, subject
      uo = user_outcome(user, action, cls, subject)
      return uo unless uo.nil?

      ro = user.roles_relation.collect{ |role| AbilityResolver.new(role, action, cls.to_s, subject).outcome }.compact
      return ro.any?{ |i| i == true } unless ro.empty?

      class_outcome(cls, action)
    end

    # ---------------------------------------------------------------------
    
    def user_outcome user, action, cls, subject
      AbilityResolver.new(user, action, cls.to_s, subject).outcome
    end

    def role_outcome role, action, cls, subject
      AbilityResolver.new(role, action, cls.to_s, subject).outcome
    end

    def class_outcome subject_class, action
      class_locks = subject_class.default_locks.select{ |l| l.action == action }
      return false if class_locks.any?(&:closed?)
      return true if class_locks.any?(&:open?)
    end

  end
end