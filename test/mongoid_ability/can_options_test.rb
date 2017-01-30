require 'test_helper'

module MongoidAbility
  describe 'can options test' do
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }

    let(:default_locks) { [MyLock1.new(action: :read, outcome: false)] }

    it 'allows to pass options to a can? block' do
      MySubject.stub :default_locks, default_locks do
        ability.can?(:read, MySubject, {}).must_equal false
        ability.can?(:read, MySubject, override: true).must_equal true
      end
    end
  end
end
