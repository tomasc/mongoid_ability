require 'test_helper'

module MongoidAbility
  describe 'basic ability test' do
    let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
    let(:owner) { MyRole.new(my_locks: [read_lock]) }
    let(:ability) { Ability.new(owner) }

    let(:default_locks) { [MyLock.new(action: :read, outcome: true)] }

    it 'owner can?' do
      MySubject.stub :default_locks, default_locks do
        ability.can?(:read, MySubject).must_equal false
      end
    end

    it 'owner cannot?' do
      MySubject.stub :default_locks, default_locks do
        ability.cannot?(:read, MySubject).must_equal true
      end
    end

    it 'is accessible by' do
      MySubject.stub :default_locks, default_locks do
        MySubject.accessible_by(ability, :read).must_be_kind_of Mongoid::Criteria
      end
    end
  end
end
