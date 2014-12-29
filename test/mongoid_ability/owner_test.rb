require 'test_helper'

module MongoidAbility
  describe Owner do

    subject { TestOwner.new }

    # =====================================================================

    describe 'fields' do
    end

    # =====================================================================

    describe 'associations' do
      it 'creates the :locks relation' do
        subject.must_respond_to :locks
      end
    end

    # =====================================================================

    describe 'class methods' do
      describe 'lock_class_name' do
        it 'finds class that includes the MongoidAbility::Lock module' do
          TestOwner.lock_class_name.must_equal 'TestLock'
        end
      end
    end

    # =====================================================================

    describe 'instance methods' do
      describe 'cleanup_locks' do
        let(:closed_lock) { TestLock.new(action: :read, outcome: false, subject_type: Object.to_s) }
        let(:open_lock) { TestLock.new(action: :read, outcome: true, subject_type: Object.to_s) }

        before do
          subject.locks = [open_lock, closed_lock].shuffle
          subject.run_callbacks(:save)
        end

        it 'prefers closed locks' do
          subject.locks.sort.must_equal [closed_lock].sort
        end
      end
    end

  end
end
