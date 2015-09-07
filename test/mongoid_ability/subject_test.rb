require 'test_helper'

module MongoidAbility
  describe Subject do

    describe '.default_lock' do
      before do
        MySubject.default_locks = []
        MySubject1.default_locks = []
        MySubject2.default_locks = []

        MySubject.default_lock MyLock, :read, true
        MySubject.default_lock MyLock, :update, true
        MySubject1.default_lock MyLock1, :update, false
      end

      it 'stores them' do
        MySubject.default_locks.map(&:action).map(&:to_s).sort.must_equal %w(read update)
        MySubject1.default_locks.map(&:action).map(&:to_s).sort.must_equal %w(update)
      end
    end

    describe 'when lock not defined on superclass' do
      before do
        MySubject.default_locks = []
        MySubject1.default_locks = []
      end

      it 'must raise error' do
        -> { MySubject1.default_lock MyLock, :test, true }.must_raise StandardError
      end
    end

    describe 'prevents conflicts' do
      before do
        MySubject.default_locks = []
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

    describe '.is_root_class?' do
      it { MySubject.is_root_class?.must_equal true }
      it { MySubject1.is_root_class?.must_equal false }
      it { MySubject2.is_root_class?.must_equal false }
    end

    describe ".root_class" do
      it { MySubject.root_class.must_equal MySubject }
      it { MySubject1.root_class.must_equal MySubject }
      it { MySubject2.root_class.must_equal MySubject }
    end

  end
end
