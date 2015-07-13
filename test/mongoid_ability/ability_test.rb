require "test_helper"

module MongoidAbility
  describe Ability do

    let(:user) { TestUser.new }
    let(:ability) { Ability.new(user) }

    # ---------------------------------------------------------------------

    it 'exposes owner' do
      ability.owner.must_equal user
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
            u.test_locks = [TestLock.new(subject_type: TestAbilitySubjectSuper2.to_s, action: :read, outcome: true)]
          end
        end
        it 'applies the superclass lock' do
          ability.can?(:read, TestAbilitySubject).must_equal true
        end
      end
    end

    # ---------------------------------------------------------------------

    describe 'role locks' do
      describe 'when multiple roles' do
        before do
          user.tap do |u|
            u.roles = [
              TestRole.new(name: 'Editor', test_locks: [
                TestLock.new(subject_type: TestAbilitySubjectSuper2.to_s, action: :read, outcome: true)
              ]),
              TestRole.new(name: 'SysOp', test_locks: [
                TestLock.new(subject_type: TestAbilitySubjectSuper2.to_s, action: :read, outcome: false)
              ])
            ]
          end
        end
        it 'prefers positive outcome' do
          ability.can?(:read, TestAbilitySubjectSuper2).must_equal true
        end
      end

      describe 'when defined for superclass' do
        before do
          user.tap do |u|
            u.roles = [
              TestRole.new(test_locks: [
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

    describe 'combined locks' do
      describe 'user and role locks' do
        before do
          user.tap do |u|
            u.test_locks = [
              TestLock.new(subject_type: TestAbilitySubjectSuper2.to_s, action: :read, outcome: false)
            ]
            u.roles = [
              TestRole.new(test_locks: [
                TestLock.new(subject_type: TestAbilitySubjectSuper2.to_s, action: :read, outcome: true)
              ])
            ]
          end
        end
        it 'prefers user locks' do
          ability.can?(:read, TestAbilitySubjectSuper2).must_equal false
        end
      end

      describe 'roles and default locks' do
        before do
          user.tap do |u|
            u.roles = [
              TestRole.new(test_locks: [
                TestLock.new(subject_type: TestAbilitySubjectSuper2.to_s, action: :read, outcome: true)
              ])
            ]
          end
        end
        it 'prefers role locks' do
          ability.can?(:read, TestAbilitySubjectSuper2).must_equal true
        end
      end
    end

    # ---------------------------------------------------------------------

    describe 'class locks' do
      it 'prefers negative outcome across same class' do
        TestAbilityResolverSubject.stub(:default_locks, [
          TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: false),
          TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: true)
        ]) do
          ability.can?(:read, TestAbilityResolverSubject).must_equal false
        end
      end
    end

  end
end
