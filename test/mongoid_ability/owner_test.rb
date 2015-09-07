require 'test_helper'

module MongoidAbility
  describe Owner do
    subject { MyOwner.new }

    describe '#cleanup_locks' do
      let(:closed_lock) { MyLock.new(action: :read, outcome: false, subject_type: Object.to_s) }
      let(:open_lock) { MyLock1.new(action: :read, outcome: true, subject_type: Object.to_s) }

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

    describe '#has_lock?' do
      let(:subject_type_lock) { MyLock.new(action: :read, subject_type: MySubject) }
      let(:subject_lock) { MyLock.new(action: :read, subject: MySubject.new) }
      let(:other_lock) { MyLock.new(action: :update, subject: MySubject.new) }
      let(:owner) { MyOwner.new(my_locks: [subject_type_lock, subject_lock]) }

      it 'returns true when lock for same action & subject_type' do
        owner.has_lock?(subject_type_lock).must_equal true
      end

      it 'returns true when lock for same action & subject' do
        owner.has_lock?(subject_lock).must_equal true
      end

      it 'returns false for non existing lock' do
        owner.has_lock?(other_lock).must_equal false
      end
    end

    describe '#inherited_locks' do
      let(:subject_type_lock) { MyLock.new(action: :read, subject_type: MySubject) }
      let(:subject_lock) { MyLock.new(action: :read, subject: MySubject.new) }
      let(:owner) { MyOwner.new(my_locks: [subject_type_lock, subject_lock]) }

      it 'returns array' do
        owner.inherited_locks.must_be_kind_of Array
      end

      it 'includes locks for missing actions' do
        owner.inherited_locks.map(&:action).must_equal %w(update)
      end
    end

  end
end
