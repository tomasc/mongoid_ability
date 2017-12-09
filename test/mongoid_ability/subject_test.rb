require 'test_helper'

module MongoidAbility
  describe Subject do
    after(:all) do
      MySubject.default_locks = []
      MySubject1.default_locks = []
      MySubject2.default_locks = []
    end

    describe '.default_lock' do
      before(:all) do
        MySubject.default_lock MyLock, :read, true
        MySubject.default_lock MyLock, :update, true
        MySubject1.default_lock MyLock1, :update, false
      end

      it { MySubject.default_locks.map(&:action).map(&:to_s).sort.must_equal %w(read update) }
      it { MySubject1.default_locks.map(&:action).map(&:to_s).sort.must_equal %w(update) }
    end

    describe 'prevents conflicts' do
      describe 'multiple locks for same action' do
        before(:all) do
          MySubject.default_lock MyLock1, :read, false
          MySubject1.default_lock MyLock, :read, true
        end

        it { MySubject.default_locks.count { |l| l.action == :read }.must_equal 1 }
      end

      describe 'replace existing locks with new attributes' do
        before(:all) do
          MySubject.default_lock MyLock1, :read, false
          MySubject1.default_lock MyLock, :read, true
        end

        it { MySubject.default_locks.detect { |l| l.action == :read }.outcome.must_equal false }
      end

      describe 'replaces existing locks with new one' do
        before(:all) do
          MySubject.default_lock MyLock1, :read, false
          MySubject1.default_lock MyLock, :read, true
        end

        it { MySubject.default_locks.detect { |l| l.action == :read }.class.must_equal MyLock1 }
      end

      describe 'replaces superclass locks' do
        before(:all) do
          MySubject.default_lock MyLock1, :read, false
          MySubject1.default_lock MyLock, :read, true
        end

        it { MySubject1.default_locks.count.must_equal 1 }
        it { MySubject1.default_locks.detect { |l| l.action == :read }.outcome.must_equal true }
      end
    end

    describe '.is_root_class?' do
      it { MySubject.is_root_class?.must_equal true }
      it { MySubject1.is_root_class?.must_equal false }
      it { MySubject2.is_root_class?.must_equal false }
    end

    describe '.root_class' do
      it { MySubject.root_class.must_equal MySubject }
      it { MySubject1.root_class.must_equal MySubject }
      it { MySubject2.root_class.must_equal MySubject }
    end
  end
end
