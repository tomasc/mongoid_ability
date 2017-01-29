require 'test_helper'

module MongoidAbility
  describe Lock do
    subject { MyLock.new }
    let(:my_subject) { MySubject.new }
    let(:inherited_lock) { MyLock1.new }

    # ---------------------------------------------------------------------

    before do
      MySubject.default_locks = [MyLock.new(action: :read, outcome: true), MyLock.new(action: :update, outcome: false)]
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

    describe '#inherited_outcome' do
      let(:my_subject) { MySubject.new }
      let(:subject_type_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
      let(:subject_lock) { MyLock.new(subject: my_subject, action: :read, outcome: true) }
      let(:owner) { MyOwner.new(my_locks: [subject_type_lock, subject_lock]) }

      before do
        @ability = Ability.new(owner) # initialize owner
      end

      it 'does not affect calculated_outcome' do
        @ability.can?(:read, my_subject).must_equal true
      end

      it 'returns calculated_outcome without this lock' do
        subject_lock.inherited_outcome.must_equal false
        subject_type_lock.inherited_outcome.must_equal true
      end

      it 'returns calculated_outcome for default locks' do
        lock = MySubject.default_locks.detect { |l| l.action == :read }
        lock.inherited_outcome.must_equal true
      end
    end
  end
end
