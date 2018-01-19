require 'test_helper'

module MongoidAbility
  describe 'can options test' do
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }
    let(:subject1) { MySubject.new }
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
end
