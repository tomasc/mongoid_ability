require "test_helper"

module MongoidAbility
  describe 'ability on Role' do

    let(:read_lock) { TestLock.new(subject_type: TestAbilitySubject.to_s, action: :read, outcome: false) }
    let(:role) { TestRole.new(test_locks: [read_lock]) }
    let(:ability) { Ability.new(role) }

    # ---------------------------------------------------------------------

    it 'role can?' do
      ability.can?(:read, TestAbilitySubject).must_equal false
    end

    it 'role cannot?' do
      ability.cannot?(:update, TestAbilitySubject).must_equal false
    end

    it 'is accessible by' do
      TestAbilitySubject.accessible_by(ability, :read).must_be_kind_of Mongoid::Criteria
    end

  end
end
