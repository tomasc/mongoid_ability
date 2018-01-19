require 'test_helper'

module MongoidAbility
  describe 'syntactic sugar' do
    let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
    let(:owner) { MyRole.new(my_locks: [read_lock]) }
    let(:ability) { Ability.new(owner) }
    let(:options) { { x: 1 } }

    before(:all) { MySubject.default_lock MyLock, :read, true }
    after(:all) { MySubject.reset_default_locks! }

    describe 'owner can?' do
      it { [MySubject].select(&ability.can_read(options)).must_equal [] }
      it { [MySubject].select(&ability.can_read?(options)).must_equal [] }

      it { ability.can_read(MySubject, options).must_equal false }
      it { ability.can_read?(MySubject, options).must_equal false }
    end

    describe 'owner cannot?' do
      it { [MySubject].select(&ability.cannot_read(options)).must_equal [MySubject] }
      it { [MySubject].select(&ability.cannot_read?(options)).must_equal [MySubject] }

      it { ability.cannot_read(MySubject, options).must_equal true }
      it { ability.cannot_read?(MySubject, options).must_equal true }
    end
  end
end
