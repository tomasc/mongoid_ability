require 'test_helper'

module MongoidAbility
  describe 'mars' do
    let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
    let(:owner) { MyRole.new(my_locks: [read_lock]) }
    let(:ability) { Ability.new(owner) }

    let(:default_locks) { [MyLock.new(action: :read, outcome: true)] }

    let(:ability_dump) { Marshal.dump(ability) }
    let(:ability_load) { Marshal.load(ability_dump) }

    it { ability_dump.must_be :present? }
    it { ability_load.send(:rules).must_equal 1 }
  end
end
