require 'test_helper'

module MongoidAbility
  describe Owner do
    subject { MyOwner.new }

    describe '#cleanup_locks' do
      let(:closed_lock) { MyLock.new(action: :read, outcome: false, subject_type: Object.to_s) }
      let(:open_lock) { MyLock_1.new(action: :read, outcome: true, subject_type: Object.to_s) }

      before do
        subject.my_locks = [open_lock, closed_lock].shuffle
        subject.run_callbacks(:save)
      end

      it 'prefers closed locks' do
        subject.my_locks.sort.must_equal [closed_lock].sort
      end

      describe 'locks relation' do
        it { subject.class.locks_relation_name.must_equal :my_locks }
        it { subject.locks_relation.metadata[:name].must_equal :my_locks }
      end
    end
  end
end
