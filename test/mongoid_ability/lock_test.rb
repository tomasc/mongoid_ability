require 'test_helper'

module MongoidAbility
  describe Lock do
    subject { MyLock.new }

    let(:my_subject) { MySubject.new }
    let(:inherited_lock) { MyLock1.new }

    after(:all) do
      MySubject.default_locks = []
      MySubject1.default_locks = []; MySubject11.default_locks = []
      MySubject2.default_locks = []; MySubject21.default_locks = []
    end

    # ---------------------------------------------------------------------

    it { subject.must_respond_to :action }
    it { subject.must_respond_to :outcome }
    it { subject.must_respond_to :subject }
    it { subject.must_respond_to :subject_id }
    it { subject.must_respond_to :subject_type }
    it { subject.must_respond_to :owner }

    # ---------------------------------------------------------------------

    it '#open?' do
      subject.must_respond_to :open?
      subject.open?.must_equal false
    end

    it '#closed?' do
      subject.must_respond_to :closed?
      subject.closed?.must_equal true
    end

    it '#class_lock?' do
      subject.must_respond_to :class_lock?
    end

    it '#id_lock?' do
      subject.must_respond_to :id_lock?
    end

    # ---------------------------------------------------------------------

    describe '.subject_id' do
      it 'converts legal id String to BSON' do
        id = BSON::ObjectId.new
        MyLock.for_subject_id(id.to_s).selector['subject_id'].must_be_kind_of BSON::ObjectId
      end

      it 'converts empty String to nil' do
        id = ''
        MyLock.for_subject_id(id.to_s).selector['subject_id'].must_be_nil
      end
    end

    # ---------------------------------------------------------------------

    describe 'sort' do
      let(:lock0) { MyLock.new(subject_type: MySubject, action: :update, outcome: false) }
      let(:lock1) { MyLock.new(subject_type: MySubject, action: :update, outcome: true) }
      let(:lock2) { MyLock.new(subject_type: MySubject, action: :read, outcome: false, options: { override: true }) }
      let(:lock3) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
      let(:lock4) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }

      let(:owner) { MyOwner.new(my_locks: [lock1, lock2, lock3, lock4]) }

      let(:sorted_locks) { owner.my_locks.sort }

      it { sorted_locks[0].must_equal lock4 }
      it { sorted_locks[3].must_equal lock1 }
    end

    # ---------------------------------------------------------------------

    describe '#inherited_outcome' do
      before(:all) { MySubject.default_lock MyLock, :read, true }

      let(:owner) { MyOwner.new(my_locks: [
        MyLock.new(subject_type: MySubject, action: :read, outcome: false),
        MyLock.new(subject: my_subject, action: :read, outcome: true)
      ]) }

      let(:ability) { Ability.new(owner) }

      let(:subject_type_lock) { owner.my_locks.detect(&:class_lock?) }
      let(:subject_lock) { owner.my_locks.detect(&:id_lock?) }
      let(:default_lock) { MySubject.default_locks.detect { |l| l.action == :read } }

      it { ability.can?(:read, my_subject).must_equal true }

      it { subject_lock.inherited_outcome.must_equal false }
      it { subject_type_lock.inherited_outcome.must_equal true }
      it { default_lock.inherited_outcome.must_equal true }
    end
  end
end
