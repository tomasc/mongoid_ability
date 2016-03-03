require 'test_helper'

module MongoidAbility
  describe Ability do
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }

    it 'exposes owner' do
      ability.owner.must_equal owner
    end

    describe 'default locks' do
      before do
        # NOTE: we might need to use the .default_lock macro in case we propagate down directly
        MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :update, outcome: true)]
        MySubject1.default_locks = []
        MySubject2.default_locks = []
      end

      it 'propagates from superclass to all subclasses' do
        ability.can?(:update, MySubject).must_equal true
        ability.can?(:update, MySubject1).must_equal true
        ability.can?(:update, MySubject2).must_equal true
      end
    end

    describe 'when defined for all superclasses' do
      before do
        MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
        MySubject1.default_locks = [MyLock.new(subject_type: MySubject1, action: :read, outcome: true)]
        MySubject2.default_locks = [MyLock.new(subject_type: MySubject2, action: :read, outcome: false)]
      end

      it 'respects the definitions' do
        ability.can?(:read, MySubject).must_equal false
        ability.can?(:read, MySubject1).must_equal true
        ability.can?(:read, MySubject2).must_equal false
      end
    end

    describe 'when defined for some superclasses' do
      before do
        MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
        MySubject1.default_locks = []
        MySubject2.default_locks = [MyLock.new(subject_type: MySubject2, action: :read, outcome: true)]
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
        before do
          MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
          MySubject1.default_locks = []
          MySubject2.default_locks = []
          owner.my_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]
        end

        it 'applies the superclass lock' do
          ability.can?(:read, MySubject2).must_equal true
        end
      end
    end

    # ---------------------------------------------------------------------

    describe 'inherited owner locks' do
      describe 'when multiple inherited owners' do
        before do
          MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
          owner.my_roles = [
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]),
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: false)])
          ]
        end

        it 'prefers positive outcome' do
          ability.can?(:read, MySubject).must_equal true
        end
      end

      describe 'when defined for superclass' do
        before do
          MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
          MySubject1.default_locks = []
          MySubject2.default_locks = []
          owner.my_roles = [MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)])]
        end

        it 'applies the superclass lock' do
          ability.can?(:read, MySubject2).must_equal true
        end
      end
    end

    # ---------------------------------------------------------------------

    describe 'combined locks' do
      describe 'user and role locks' do
        before do
          MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
          owner.my_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
          owner.my_roles = [MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)])]
        end

        it 'prefers user locks' do
          ability.can?(:read, MySubject).must_equal false
        end
      end

      describe 'roles and default locks' do
        before do
          MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
          owner.my_roles = [MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)])]
        end

        it 'prefers role locks' do
          ability.can?(:read, MySubject).must_equal true
        end
      end
    end
  end
end
