require 'test_helper'

module MongoidAbility
  describe FindLock do
    let(:owner) { MyOwner.new }

    describe 'default lock' do
      before { MySubject.default_lock MyLock, :read, true }

      it { FindLock.call(owner, :read, MySubject).must_equal MySubject.default_locks.for_action(:read).first }
      it { FindLock.call(owner, :read, MySubject1).must_equal MySubject.default_locks.for_action(:read).first }
    end

    describe 'inherited lock' do
      before { MySubject.default_lock MyLock, :read, true }

      let(:lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
      let(:role) { MyRole.new(my_locks: [lock]) }
      let(:owner) { MyOwner.new(my_roles: [role]) }

      it { FindLock.call(owner, :read, MySubject).must_equal lock }
    end

    describe 'owned lock' do
      before { MySubject.default_lock MyLock, :read, true }

      let(:lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
      let(:owner) { MyOwner.new(my_locks: [lock]) }

      it { FindLock.call(owner, :read, MySubject).must_equal lock }

      describe 'id lock' do
        let(:my_subject) { MySubject.new }
        let(:lock) { MyLock.new(subject: my_subject, action: :read, outcome: false) }
        let(:owner) { MyOwner.new(my_locks: [lock]) }

        it { FindLock.call(owner, :read, MySubject).must_equal MySubject.default_locks.for_action(:read).first }
        it { FindLock.call(owner, :read, my_subject.class, my_subject.id).must_equal lock }
      end
    end
  end
end
