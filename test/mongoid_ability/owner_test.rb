require 'test_helper'

module MongoidAbility
  describe Owner do

    subject { TestOwner.new }

    # =====================================================================

    describe 'fields' do
    end

    # =====================================================================

    describe 'associations' do
    end

    # =====================================================================

    describe 'class methods' do
      describe 'lock_class_name' do
        it 'finds class that includes the MongoidAbility::Lock module' do
          TestOwner.lock_class_name.must_equal 'TestLock'
        end
      end

      describe 'locks_relation_name' do
        it 'finds the name of relation that contains locks' do
          TestOwner.locks_relation_name.must_equal :test_locks
        end
      end
    end

    # =====================================================================

    describe 'instance methods' do
      describe 'cleanup_locks' do
        let(:closed_lock) { TestLock.new(action: :read, outcome: false, subject_type: Object.to_s) }
        let(:open_lock) { TestLock.new(action: :read, outcome: true, subject_type: Object.to_s) }

        before do
          subject.test_locks = [open_lock, closed_lock].shuffle
          subject.run_callbacks(:save)
        end

        it 'prefers closed locks' do
          subject.test_locks.sort.must_equal [closed_lock].sort
        end
      end
    end

  end
end
