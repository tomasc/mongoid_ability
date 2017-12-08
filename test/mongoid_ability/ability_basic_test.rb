require 'test_helper'

module MongoidAbility
  describe 'basic ability test' do
    let(:owner) { MyRole.new }
    let(:ability) { Ability.new(owner) }

    describe 'default' do
      before(:all) { MySubject.default_locks = [] }
      after(:all) { MySubject.default_locks = [] }

      it { ability.can?(:read, MySubject).must_equal false }
      it { ability.cannot?(:read, MySubject).must_equal true }
    end

    describe 'class locks' do
      before(:all) { MySubject.default_lock MyLock, :read, true }
      after(:all) { MySubject.default_locks = [] }

      it { ability.can?(:read, MySubject).must_equal true }
      it { ability.cannot?(:read, MySubject).must_equal false }
    end

    describe 'inherited locks' do
      describe 'subject_type' do
        let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
        let(:my_role) { MyRole.new(my_locks: [read_lock]) }
        let(:owner) { MyOwner.new(my_roles: [my_role]) }

        it { ability.can?(:read, MySubject).must_equal true }
        it { ability.cannot?(:read, MySubject).must_equal false }
      end

      describe 'subject_id' do
        let(:my_subject) { MySubject.new }
        let(:read_lock) { MyLock.new(subject: my_subject, action: :read, outcome: true) }
        let(:my_role) { MyRole.new(my_locks: [read_lock]) }
        let(:owner) { MyOwner.new(my_roles: [my_role]) }

        it { ability.can?(:read, my_subject).must_equal true }
        it { ability.cannot?(:read, my_subject).must_equal false }
      end
    end

    describe 'owner locks' do
      describe 'subject_type' do
        let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
        let(:owner) { MyOwner.new(my_locks: [read_lock]) }

        it { ability.can?(:read, MySubject).must_equal true }
        it { ability.cannot?(:read, MySubject).must_equal false }
      end

      describe 'subject_id' do
        let(:my_subject) { MySubject.new }
        let(:read_lock) { MyLock.new(subject: my_subject, action: :read, outcome: true) }
        let(:owner) { MyOwner.new(my_locks: [read_lock]) }

        it { ability.can?(:read, my_subject).must_equal true }
        it { ability.cannot?(:read, my_subject).must_equal false }
      end
    end
  end
end
