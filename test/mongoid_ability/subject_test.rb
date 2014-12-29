require 'test_helper'

module MongoidAbility
  describe Subject do

    subject { MySubject.new }
    let(:subject_super) { MySubjectSuper.new }

    # =====================================================================

    describe 'fields' do
    end

    # =====================================================================

    describe 'associations' do
    end

    # =====================================================================

    describe 'class methods' do
      it 'has .default_locks' do
        subject.class.must_respond_to :default_locks
        subject.class.default_locks.must_be_kind_of Array
      end

      it 'has .default_lock' do
        subject.class.must_respond_to :default_lock
      end

      describe '.default_lock' do
        it 'sets up new Lock' do
          lock = subject.class.default_locks.first
          subject.class.default_locks.length.must_equal 1
          lock.subject_type.must_equal subject.class.model_name
          lock.subject_id.must_be_nil
          lock.action.must_equal :read
        end
      end

      # ---------------------------------------------------------------------
        
      describe '.ancestors_with_default_locks' do
        it 'lists ancestors with default locks' do
          subject.class.ancestors_with_default_locks.must_equal [MySubjectSuper]
        end
      end

      describe '.self_and_ancestors_with_default_locks' do
        it 'lists self and ancestors with default locks' do
          subject.class.self_and_ancestors_with_default_locks.must_equal [MySubject, MySubjectSuper]
        end
      end

      # ---------------------------------------------------------------------
        
      describe '.accessible_by' do
        # it 'returns Mongoid::Criteria' do
        #   subject.class.accessible_by(ability).must_be_kind_of Mongoid::Criteria
        # end

        # describe 'when closed lock on user' do
        #   before { user.locks = [closed_lock] }
        #   it 'returns criteria excluding such ids' do
        #     subject.class.accessible_by(ability).selector.fetch('_id', {}).fetch('$nin', []).must_include subject.id
        #   end
        # end

        # describe "when closed lock on user's role" do
        #   before { user.roles = [FactoryGirl.build(:role, locks: [closed_lock])] }
        #   it 'returns criteria excluding such ids' do
        #     subject.class.accessible_by(ability).selector.fetch('_id', {}).fetch('$nin', []).must_include subject.id
        #   end
        # end

        # describe "when class does not permit" do
        #   before do
        #     user.locks = [open_lock]
        #   end
        #   it 'returns criteria excluding everything but open id_locks' do
        #     subject.class.stub(:default_locks, [FactoryGirl.build(:closed_lock, action: :read, subject_type: subject.class, outcome: false)]) do
        #       subject.class.accessible_by(ability).selector.fetch('_id', {}).fetch('$in', []).must_include subject.id
        #     end
        #   end
        # end
        
      end
    end
  end

  # =====================================================================

  describe 'instance methods' do
  end

end
