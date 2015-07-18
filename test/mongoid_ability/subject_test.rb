require 'test_helper'

module MongoidAbility
  describe Subject do
    describe '.default_locks' do

      before do
        MySubject.default_locks = []
        MySubject1.default_locks = []

        MySubject.default_lock MyLock, :read, true
        MySubject1.default_lock MyLock1, :update, false
      end

      it 'stores them' do
        MySubject.default_locks.map(&:action).map(&:to_s).sort.must_equal %w(read)
        MySubject1.default_locks.map(&:action).map(&:to_s).sort.must_equal %w(update)
      end

      describe 'prevents conflicts' do
        before do
          # FIXME: this permanently adjusts the default test locks – ideally do this other way, stubs etc.
          MySubject.default_lock MyLock, :read, false
          MySubject.default_lock MyLock1, :read, false
        end

        it 'does not allow multiple locks for same action' do
          MySubject.default_locks.select{ |l| l.action == :read }.count.must_equal 1
        end

        it 'replace existing locks with new attributes' do
          MySubject.default_locks.detect{ |l| l.action == :read }.outcome.must_equal false
        end

        it 'replaces existing locks with new one' do
          MySubject.default_locks.detect{ |l| l.action == :read }.class.must_equal MyLock1
        end
      end

    end
  end
end
