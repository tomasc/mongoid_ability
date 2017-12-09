require 'test_helper'

module MongoidAbility
  describe Ability do
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }

    after(:all) do
      MySubject.default_locks = []
      MySubject1.default_locks = []
      MySubject2.default_locks = []
    end

    it 'exposes owner' do
      ability.owner.must_equal owner
    end

    describe 'default locks' do
      before(:all) { MySubject.default_lock MyLock, :update, true }
      after(:all) { MySubject.default_locks = [] }

      it 'propagates from superclass to all subclasses' do
        ability.can?(:update, MySubject).must_equal true
        ability.can?(:update, MySubject1).must_equal true
        ability.can?(:update, MySubject2).must_equal true
      end
    end

    describe 'when defined for all superclasses' do
      before(:all) do
        MySubject.default_lock MyLock, :read, false
        MySubject1.default_lock MyLock, :read, true
        MySubject2.default_lock MyLock, :read, false
      end

      it { ability.can?(:read, MySubject).must_equal false }
      it { ability.can?(:read, MySubject1).must_equal true }
      it { ability.can?(:read, MySubject2).must_equal false }
    end

    describe 'when defined for some superclasses' do
      before(:all) do
        MySubject.default_lock MyLock, :read, false
        MySubject1.default_locks = []
        MySubject2.default_lock MyLock, :read, true
      end

      it 'propagates default locks to subclasses' do
        ability.can?(:read, MySubject).must_equal false
        ability.can?(:read, MySubject1).must_equal false
        ability.can?(:read, MySubject2).must_equal true
      end
    end

    # ---------------------------------------------------------------------

    describe 'user locks' do
      describe 'when defined for superclass' do
        let(:owner) { MyOwner.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]) }
        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { ability.can?(:read, MySubject2).must_equal true }
      end
    end

    # ---------------------------------------------------------------------

    describe 'inherited owner locks' do
      describe 'when multiple inherited owners' do
        let(:owner) do
          MyOwner.new(my_roles: [
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]),
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]),
          ])
        end

        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { ability.can?(:read, MySubject).must_equal true }
      end

      describe 'when defined for superclass' do
        let(:owner) do
          MyOwner.new(my_roles: [
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)])
          ])
        end

        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { ability.can?(:read, MySubject2).must_equal true }
      end
    end

    # ---------------------------------------------------------------------

    describe 'combined locks' do
      describe 'user and role locks' do
        let(:role_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
        let(:owner_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }

        let(:role) { MyRole.new(my_locks: [role_lock]) }
        let(:owner) { MyOwner.new(my_locks: [owner_lock], my_roles: [role]) }

        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { ability.can?(:read, MySubject).must_equal false }
      end

      describe 'roles and default locks' do
        let(:role_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }

        let(:role) { MyRole.new(my_locks: [role_lock]) }
        let(:owner) { MyOwner.new(my_roles: [role]) }

        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { ability.can?(:read, MySubject).must_equal true }
      end
    end
  end
end
