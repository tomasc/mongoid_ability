require 'cancancan'
  
module MongoidAbility
  class Ability

    include CanCan::Ability

    # ---------------------------------------------------------------------
    
    attr_reader :user

    # =====================================================================

    def initialize user
      @user = user
      
      can do |action, subject_type, subject|
        subject_class = subject_type.to_s.constantize
        outcome = nil
        subject_class.self_and_ancestors_with_default_locks.each do |cls|
          outcome = AbilityResolver.new(user, action, cls.to_s, subject).outcome
          break unless outcome.nil?
        end
        outcome
      end
    end

  end
end