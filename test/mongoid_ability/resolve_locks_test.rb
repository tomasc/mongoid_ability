require 'test_helper'

module MongoidAbility
  describe ResolveLocks do

    let(:owner) { MyOwner.new }

    describe 'errors' do
      it 'raises NameError for invalid subject_type' do
        -> { ResolveLocks.call(owner, :read, 'Foo') }.must_raise NameError
      end

      it 'raises StandardError when subject_type does not have default_locks' do
        -> { ResolveLocks.call(owner, :read, Object) }.must_raise StandardError
      end

      it 'raises StandardError when subject_type class or its ancestors does not have default_lock' do
        MySubject.stub(:default_locks, []) do
          -> { ResolveLocks.call(owner, :read, MySubject) }.must_raise StandardError
        end
      end
    end

  end
end
