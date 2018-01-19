require 'test_helper'

module MongoidAbility
  describe FindLock do
    let(:owner) { MyOwner.new }

    describe 'default lock' do
      before { MySubject.default_lock MyLock, :read, true }

      it { FindLock.call(owner, :read, MySubject).must_equal MySubject.default_locks.first }
      it { FindLock.call(owner, :read, MySubject1).must_equal MySubject.default_locks.first }
    end
  end
end
