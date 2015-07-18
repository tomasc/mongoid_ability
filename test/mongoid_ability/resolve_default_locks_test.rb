require "test_helper"

module MongoidAbility
  describe ResolveDefaultLocks do

    describe '.call' do
      before do
        MySubject.default_locks = [
          MyLock.new(subject_type: MySubject, action: :read, outcome: true),
          MyLock.new(subject_type: MyLock_1, action: :update, outcome: false)
        ]
      end

      it { ResolveDefaultLocks.call(nil, :read, MySubject, nil, {}).must_equal true }
      it { ResolveDefaultLocks.call(nil, :update, MySubject, nil, {}).must_equal false }
    end

  end
end
