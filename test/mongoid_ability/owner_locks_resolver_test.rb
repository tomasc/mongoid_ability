require "test_helper"

module MongoidAbility
  describe OwnerLocksResolver do
    let(:owner) { MyOwner.new }
    let(:my_subject) { MySubject.new }

    subject { OwnerLocksResolver.new(owner, :read, MySubject, nil) }
    let(:resolver_for_subject_id) { OwnerLocksResolver.new(owner, :read, MySubject, my_subject) }

    # =====================================================================

    describe 'errors' do
      it 'raises NameError for invalid subject_type' do
        -> { ar = OwnerLocksResolver.new(user, :read, 'Foo') }.must_raise NameError
      end

      it 'raises StandardError when subject_type does not have default_locks' do
        -> { ar = OwnerLocksResolver.new(user, :read, Object) }.must_raise StandardError
      end

      it 'raises StandardError when subject_type class or its ancestors does not have default_lock' do
        MySubject.stub(:default_locks, []) do
          -> { ar = OwnerLocksResolver.new(user, :read, MySubject) }.must_raise StandardError
        end
      end
    end

    # ---------------------------------------------------------------------

    describe '#outcome' do
      describe 'no locks' do
        it { subject.outcome.must_be_nil }
      end

      describe 'id locks' do
        it 'returns outcome' do
          owner.locks = [ MyLock.new(action: :read, subject: my_subject, outcome: true) ]
          resolver_for_subject_id.outcome.must_equal true
        end

        it 'prefers negative outcome' do
          owner.locks = [ MyLock.new(action: :read, subject: my_subject, outcome: true),
                          MyLock.new(action: :read, subject: my_subject, outcome: false) ]
          resolver_for_subject_id.outcome.must_equal false
        end
      end

      describe 'class locks' do
        it 'returns outcome' do
          owner.locks = [ MyLock.new(action: :read, subject_type: MySubject, outcome: true) ]
          subject.outcome.must_equal true
        end

        it 'prefers negative outcome' do
          owner.locks = [ MyLock.new(action: :read, subject_type: MySubject, outcome: true),
                          MyLock.new(action: :read, subject_type: MySubject, outcome: false) ]
          subject.outcome.must_equal false
        end
      end
    end

  end
end
