require 'test_helper'

module MongoidAbility
  describe Lock do
    subject { MyLock.new }
    let(:my_subject) { MySubject.new }
    let(:inherited_lock) { MyLock_1.new }

    it { subject.must_respond_to :action }
    it { subject.must_respond_to :outcome }
    it { subject.must_respond_to :subject }
    it { subject.must_respond_to :subject_id }
    it { subject.must_respond_to :subject_type }
    it { subject.must_respond_to :owner }

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

    describe '#criteria' do
      let(:open_subject_type_lock) {  MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
      let(:closed_subject_type_lock) {  MyLock.new(subject_type: MySubject, action: :read, outcome: false) }

      let(:open_subject_lock) {  MyLock.new(subject: my_subject, action: :read, outcome: true) }
      let(:closed_subject_lock) {  MyLock.new(subject: my_subject, action: :read, outcome: false) }

      it 'returns conditions Hash' do
        open_subject_type_lock.conditions.must_be_kind_of Hash
        closed_subject_type_lock.conditions.must_be_kind_of Hash

        open_subject_lock.conditions.must_be_kind_of Hash
        closed_subject_lock.conditions.must_be_kind_of Hash
      end

      describe 'when open' do
        it 'includes subject_type' do
          open_subject_type_lock.conditions.must_equal({ _type: open_subject_type_lock.subject_type })
        end

        it 'includes id' do
          open_subject_lock.conditions.must_equal({ _type: open_subject_type_lock.subject_type, _id: open_subject_lock.subject_id })
        end
      end

      describe 'when closed' do
        it 'excludes subject_type' do
          closed_subject_type_lock.conditions.must_equal({ '$not' => { _type: open_subject_type_lock.subject_type }})
        end

        it 'includes id' do
          closed_subject_lock.conditions.must_equal({ '$not' => { _type: open_subject_type_lock.subject_type, _id: open_subject_lock.subject_id }})
        end
      end
    end
  end
end
