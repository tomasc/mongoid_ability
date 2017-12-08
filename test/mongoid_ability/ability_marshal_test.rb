require 'test_helper'

module MongoidAbility
  describe 'marshal' do
    let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
    let(:owner) { MyRole.new(my_locks: [read_lock]) }
    let(:ability) { Ability.new(owner) }

    let(:ability_dump) { Marshal.dump(ability) }
    let(:ability_load) { Marshal.load(ability_dump) }

    before(:all) { MySubject.default_lock MyLock, :read, true }
    after(:all) { MySubject.default_locks = [] }

    it { ability_dump.must_be :present? }
    it { ability_load.send(:rules).count.must_equal 2 }
  end
end
