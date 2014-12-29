require 'test_helper'

module MongoidAbility
  describe Lock do

    subject { MyLock.new }
    
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
    end

  end
end