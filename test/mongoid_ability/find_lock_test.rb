require 'test_helper'

module MongoidAbility
  describe FindLock do
    after(:all) do
      MySubject.reset_default_locks!
      MySubject1.reset_default_locks!; MySubject11.reset_default_locks!
      MySubject2.reset_default_locks!; MySubject21.reset_default_locks!
    end

    let(:owner) { MyOwner.new }
    let(:action) { :read }
    let(:subject_type) { MySubject }
    let(:subject_id) { nil }

    let(:result) { FindLock.call(owner, action, subject_type, subject_id) }

    describe 'default lock' do
      before { MySubject.default_lock MyLock, :read, true }

      it { result.must_equal MySubject.default_locks.first }
    end
  end
end
