require "test_helper"

module MongoidAbility
  describe 'ability on Role' do

    let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
    let(:role) { MyRole.new(my_locks: [ read_lock ]) }
    let(:ability) { Ability.new(role) }

    # ---------------------------------------------------------------------

    it 'role can?' do
      ability.can?(:read, MySubject).must_equal false
    end

    it 'role cannot?' do
      ability.cannot?(:read, MySubject).must_equal true
    end

    it 'is accessible by' do
      MySubject.accessible_by(ability, :read).must_be_kind_of Mongoid::Criteria
    end

  end
end
