require "test_helper"

module MongoidAbility
  describe ResolveDefaultLocks do

    describe '.call' do
      before do
        MySubject.default_lock MyLock, :read, true
        MySubject.default_lock MyLock_1, :update, false
      end
      
      it { ResolveDefaultLocks.call(nil, :read, MySubject, nil, {}).must_equal true }
      it { ResolveDefaultLocks.call(nil, :update, MySubject, nil, {}).must_equal false }
    end

  end
end
