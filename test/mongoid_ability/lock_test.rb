require 'test_helper'

module MongoidAbility
  describe Lock do

    let(:subject_test) { SubjectTest.new }
    subject { TestLock.new }
    
    # =====================================================================

    describe 'fields' do
      it 'has :action' do
        subject.must_respond_to :action
        subject.action.must_be_kind_of Symbol
      end

      it 'has :outcome' do
        subject.must_respond_to :outcome
        subject.outcome.must_equal false
      end
    end

    # =====================================================================
      
    describe 'associations' do
      it 'embedded in :owner' do
        subject.must_respond_to :owner
        subject.relations['owner'].macro.must_equal :embedded_in
      end

      it 'belongs to :subject' do
        subject.must_respond_to :subject
        subject.must_respond_to :subject_type
        subject.must_respond_to :subject_id
      end
    end
    
    # =====================================================================

    describe 'instance methods' do
      it 'has #open?' do
        subject.must_respond_to :open?
        subject.open?.must_equal false
      end
      it 'has #closed?' do
        subject.must_respond_to :closed?
        subject.closed?.must_equal true
      end
      it 'has #class_lock?' do
        subject.must_respond_to :class_lock?
      end
      it 'has #id_lock?' do
        subject.must_respond_to :id_lock?
      end

      describe '#criteria' do
        let(:open_subject_type_lock) {  TestLock.new(subject_type: subject_test.class.to_s, action: :read, outcome: true) }
        let(:closed_subject_type_lock) {  TestLock.new(subject_type: subject_test.class.to_s, action: :read, outcome: false) }

        let(:open_subject_lock) {  TestLock.new(subject: subject_test, action: :read, outcome: true) }
        let(:closed_subject_lock) {  TestLock.new(subject: subject_test, action: :read, outcome: false) }

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
end