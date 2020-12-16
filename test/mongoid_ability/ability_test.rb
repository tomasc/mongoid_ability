require 'test_helper'

module MongoidAbility
  describe Ability do
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }

    it 'exposes owner' do
      _(ability.owner).must_equal owner
    end

    describe 'default locks' do
      after(:all) do
        [MySubject, MySubject1, MySubject2, MySubject11, MySubject21]
          .each(&:reset_default_locks!)
      end

      it 'propagates from superclass to subclasses' do
        MySubject.default_lock MyLock, :update, true

        _(ability.can?(:update, MySubject)).must_equal true
        _(ability.can?(:update, MySubject1)).must_equal true
        _(ability.can?(:update, MySubject2)).must_equal true
      end

      it 'supersedes superclass locks' do
        MySubject.default_lock MyLock, :read, false
        MySubject1.default_lock MyLock, :read, true
        MySubject2.default_lock MyLock, :read, false

        _(ability.can?(:read, MySubject)).must_equal false
        _(ability.can?(:read, MySubject1)).must_equal true
        _(ability.can?(:read, MySubject2)).must_equal false
      end
    end

    describe 'when defined for some superclasses' do
      before(:all) do
        MySubject.default_lock MyLock, :read, false
        MySubject1.reset_default_locks!
        MySubject2.default_lock MyLock, :read, true
      end

      it 'propagates default locks to subclasses' do
        _(ability.can?(:read, MySubject)).must_equal false
        _(ability.can?(:read, MySubject1)).must_equal false
        _(ability.can?(:read, MySubject2)).must_equal true
      end
    end

    describe 'user locks' do
      describe 'when defined for superclass' do
        let(:owner) { MyOwner.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]) }
        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { _(ability.can?(:read, MySubject2)).must_equal true }
      end
    end

    describe 'inherited owner locks' do
      describe 'when multiple inherited owners' do
        let(:owner) do
          MyOwner.new(my_roles: [
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]),
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]),
          ])
        end

        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { _(ability.can?(:read, MySubject)).must_equal true }
      end

      describe 'when defined for superclass' do
        let(:owner) do
          MyOwner.new(my_roles: [
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)])
          ])
        end

        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { _(ability.can?(:read, MySubject2)).must_equal true }
      end
    end

    describe 'combined locks' do
      describe 'user and role locks' do
        let(:role_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
        let(:owner_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }

        let(:role) { MyRole.new(my_locks: [role_lock]) }
        let(:owner) { MyOwner.new(my_locks: [owner_lock], my_roles: [role]) }

        before(:all) { MySubject.default_lock MyLock, :read, false }

        it { _(ability.can?(:read, MySubject)).must_equal false }
      end

      describe 'roles and default locks' do
        describe 'negative positive' do
          before(:all) { MySubject.default_lock MyLock, :read, false }

          let(:lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
          let(:role) { MyRole.new(my_locks: [lock]) }
          let(:owner) { MyOwner.new(my_roles: [role]) }

          it { _(ability.can?(:read, MySubject)).must_equal true }

          describe 'subclass' do
            let(:lock) { MyLock.new(subject_type: MySubject1, action: :read, outcome: true) }

            it { _(ability.can?(:read, MySubject)).must_equal false }
            it { _(ability.can?(:read, MySubject1)).must_equal true }
          end
        end

        describe 'positive negative' do
          before(:all) { MySubject.default_lock MyLock, :read, true }

          let(:lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
          let(:role) { MyRole.new(my_locks: [lock]) }
          let(:owner) { MyOwner.new(my_roles: [role]) }

          it { _(ability.can?(:read, MySubject)).must_equal false }

          describe 'subclass' do
            let(:lock) { MyLock.new(subject_type: MySubject1, action: :read, outcome: false) }

            it { _(ability.can?(:read, MySubject)).must_equal true }
            it { _(ability.can?(:read, MySubject1)).must_equal false }
          end
        end

        describe 'positive negative positive' do
          before(:all) do
            MySubject.default_lock MyLock, :read, true
            MySubject1.default_lock MyLock, :read, false
          end

          let(:lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
          let(:role) { MyRole.new(my_locks: [lock]) }
          let(:owner) { MyOwner.new(my_roles: [role]) }

          it { _(ability.can?(:read, MySubject)).must_equal true }
          it { _(ability.can?(:read, MySubject1)).must_equal false }
        end
      end
    end
  end
end
