require 'test_helper'

module MongoidAbility
  describe 'syntactic sugar' do
    let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
    let(:role) { MyRole.new(my_locks: [read_lock]) }
    let(:ability) { Ability.new(role) }

    before do
      MySubject.default_locks = [MyLock.new(action: :read, outcome: true)]
    end

    it 'role can?' do
      ability.can_read(MySubject).must_equal false
      ability.can_read?(MySubject).must_equal false
    end

    it 'role cannot?' do
      ability.cannot_read(MySubject).must_equal true
      ability.cannot_read?(MySubject).must_equal true
    end
  end
end
