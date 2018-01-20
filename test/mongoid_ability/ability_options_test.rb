require 'test_helper'

module MongoidAbility
  describe 'can options test' do
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }
    let(:subject1) { MySubject.new }

    describe 'Boolean' do
      let(:subject2) { MySubject.new(override: true) }

      describe 'positive' do
        before(:all) { MySubject.default_lock MyLock, :read, true, override: true }

        it { ability.can?(:read, subject1).must_equal false }
        it { ability.can?(:read, subject2).must_equal true }
      end

      describe 'negative' do
        before(:all) do
          MySubject.default_lock MyLock, :read, true
          MySubject.default_lock MyLock, :read, false, override: true
        end

        it { ability.can?(:read, subject1).must_equal true }
        it { ability.can?(:read, subject2).must_equal false }
      end
    end

    describe 'String' do
      let(:subject2) { MySubject.new(str_val: "Jan Tschichold") }

      describe 'positive' do
        before(:all) { MySubject.default_lock MyLock, :read, true, str_val: 'Jan Tschichold' }

        it { ability.can?(:read, subject1).must_equal false }
        it { ability.can?(:read, subject2).must_equal true }
      end

      describe 'negative' do
        before(:all) do
          MySubject.default_lock MyLock, :read, true
          MySubject.default_lock MyLock, :read, false, str_val: 'Jan Tschichold'
        end

        it { ability.can?(:read, subject1).must_equal true }
        it { ability.can?(:read, subject2).must_equal false }
      end
    end

    describe 'Regexp' do
      let(:subject2) { MySubject.new(str_val: "Jan Tschichold") }

      describe 'positive' do
        before(:all) { MySubject.default_lock MyLock, :read, true, str_val: /tschichold/i }

        it { ability.can?(:read, subject1).must_equal false }
        it { ability.can?(:read, subject2).must_equal true }
      end

      describe 'negative' do
        before(:all) do
          MySubject.default_lock MyLock, :read, true
          MySubject.default_lock MyLock, :read, false, str_val: /tschichold/i
        end

        it { ability.can?(:read, subject1).must_equal true }
        it { ability.can?(:read, subject2).must_equal false }
      end
    end

    describe 'Array' do
      let(:subject2) { MySubject.new(str_val: "John") }

      describe 'positive' do
        before(:all) { MySubject.default_lock MyLock, :read, true, str_val: %w(John Paul George Ringo) }

        it { ability.can?(:read, subject1).must_equal false }
        it { ability.can?(:read, subject2).must_equal true }
      end

      describe 'negative' do
        before(:all) do
          MySubject.default_lock MyLock, :read, true
          MySubject.default_lock MyLock, :read, false, str_val: %w(John Paul George Ringo)
        end

        it { ability.can?(:read, subject1).must_equal true }
        it { ability.can?(:read, subject2).must_equal false }
      end
    end
  end
end
