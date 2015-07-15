require "test_helper"

module MongoidAbility
  describe ResolveOwnerLocks do
    let(:owner) { MyOwner.new }
    let(:my_subject) { MySubject.new }

    subject { ResolveOwnerLocks.call(owner, :read, MySubject, nil) }
    let(:resolver_for_subject_id) { ResolveOwnerLocks.call(owner, :read, MySubject, my_subject) }

    # =====================================================================

    describe 'errors' do
      it 'raises NameError for invalid subject_type' do
        -> { ResolveOwnerLocks.call(user, :read, 'Foo') }.must_raise NameError
      end

      it 'raises StandardError when subject_type does not have default_locks' do
        -> { ResolveOwnerLocks.call(user, :read, Object) }.must_raise StandardError
      end

      it 'raises StandardError when subject_type class or its ancestors does not have default_lock' do
        MySubject.stub(:default_locks, []) do
          -> { ResolveOwnerLocks.call(user, :read, MySubject) }.must_raise StandardError
        end
      end
    end

    # ---------------------------------------------------------------------

    describe '#outcome' do
      describe 'no locks' do
        it { subject.must_be_nil }
      end

      describe 'id locks' do
        it 'returns outcome' do
          owner.locks = [ MyLock.new(action: :read, subject: my_subject, outcome: true) ]
          resolver_for_subject_id.must_equal true
        end

        it 'prefers negative outcome' do
          owner.locks = [ MyLock.new(action: :read, subject: my_subject, outcome: true),
                          MyLock.new(action: :read, subject: my_subject, outcome: false) ]
          resolver_for_subject_id.must_equal false
        end
      end

      describe 'class locks' do
        it 'returns outcome' do
          owner.locks = [ MyLock.new(action: :read, subject_type: MySubject, outcome: true) ]
          subject.must_equal true
        end

        it 'prefers negative outcome' do
          owner.locks = [ MyLock.new(action: :read, subject_type: MySubject, outcome: true),
                          MyLock.new(action: :read, subject_type: MySubject, outcome: false) ]
          subject.must_equal false
        end
      end
    end

  end
end
