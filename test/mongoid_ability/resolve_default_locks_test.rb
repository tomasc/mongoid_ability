require 'test_helper'

module MongoidAbility
  describe ResolveDefaultLocks do
    describe '.call' do
      let(:options) { {} }

      before do
        MySubject.default_locks = [
          MyLock.new(subject_type: MySubject, action: :read, outcome: true),
          MyLock.new(subject_type: MySubject, action: :update, outcome: false)
        ]

        MySubject1.default_locks = [
          MyLock.new(subject_type: MySubject1, action: :read, outcome: false),
          MyLock.new(subject_type: MySubject1, action: :update, outcome: true)
        ]
      end

      it { ResolveDefaultLocks.call(nil, :read, MySubject, nil, options).must_equal MySubject.default_locks.first }
      it { ResolveDefaultLocks.call(nil, :update, MySubject, nil, options).must_equal MySubject.default_locks.last }

      it { ResolveDefaultLocks.call(nil, :read, MySubject1, nil, options).must_equal MySubject1.default_locks.first }
      it { ResolveDefaultLocks.call(nil, :update, MySubject1, nil, options).must_equal MySubject1.default_locks.last }
    end
  end
end
