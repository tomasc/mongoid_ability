require 'test_helper'

module MongoidAbility
  describe 'marshal' do
    before(:all) { MySubject.default_lock MyLock, :read, true }
    after(:all) { MySubject.reset_default_locks! }

    let(:read_lock) { MyLock.new(subject_type: MySubject1, action: :read, outcome: false) }
    let(:owner) { MyRole.new(my_locks: [read_lock]) }
    let(:ability) { Ability.new(owner) }

    let(:ability_dump) { Marshal.dump(ability) }
    let(:ability_load) { Marshal.load(ability_dump) }

    it { ability_dump.must_be :present? }
    it { ability_load.send(:rules).count.must_equal 2 }
  end
end
