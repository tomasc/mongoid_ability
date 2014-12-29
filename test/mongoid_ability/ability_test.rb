require "test_helper"

module MongoidAbility
  describe Ability do

    let(:user) { TestUser.new }
    let(:ability) { Ability.new(user) }

    # ---------------------------------------------------------------------
    
    describe 'user' do
      it 'exposes user' do
        ability.user.must_equal user
      end
    end

    # ---------------------------------------------------------------------
    
    describe 'default locks' do
      it 'propagates from superclass to all subclasses' do
        ability.can?(:update, TestAbilitySubjectSuper1).must_equal true
        ability.can?(:update, TestAbilitySubject).must_equal true
      end

      describe 'when defined for all superclasses' do
        it 'propagates default locks to subclasses' do
          ability.can?(:read, TestAbilitySubjectSuper2).must_equal false
          TestAbilitySubjectSuper1.stub(:default_locks, [
            TestLock.new(subject_type: TestAbilitySubjectSuper1.to_s, action: :read, outcome: false)
          ]) do
            ability.can?(:read, TestAbilitySubjectSuper1).must_equal false
          end
          TestAbilitySubject.stub(:default_locks, [
            TestLock.new(subject_type: TestAbilitySubject.to_s, action: :read, outcome: true)
          ]) do
            ability.can?(:read, TestAbilitySubject).must_equal true
          end
        end      
      end

      describe 'when defined for some superclasses' do
        it 'propagates default locks to subclasses' do
          ability.can?(:read, TestAbilitySubjectSuper2).must_equal false
          ability.can?(:read, TestAbilitySubjectSuper1).must_equal false
          TestAbilitySubject.stub(:default_locks, [
            TestLock.new(subject_type: TestAbilitySubjectSuper1.to_s, action: :read, outcome: true)
          ]) do
            ability.can?(:read, TestAbilitySubject).must_equal true
          end
        end  
      end
    end

    # ---------------------------------------------------------------------
    
    describe 'user locks' do
      describe 'when defined for superclass' do
        before do
          user.tap do |u|
            u.locks = [TestLock.new(subject_type: TestAbilitySubjectSuper2.to_s, action: :read, outcome: true)]
          end
        end
        it 'applies the superclass lock' do
          ability.can?(:read, TestAbilitySubject).must_equal true
        end
      end
    end

    # ---------------------------------------------------------------------
    
    describe 'role locks' do
      describe 'when defined for superclass' do
        before do
          user.tap do |u|
            u.roles = [
              TestRole.new(locks: [
                TestLock.new(subject_type: TestAbilitySubjectSuper2.to_s, action: :read, outcome: true)
              ])
            ]
          end
        end
        it 'applies the superclass lock' do
          ability.can?(:read, TestAbilitySubject).must_equal true
        end
      end
    end

    # ---------------------------------------------------------------------
    
  end
end