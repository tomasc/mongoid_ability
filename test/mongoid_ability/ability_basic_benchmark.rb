require 'test_helper'
require 'minitest/benchmark'

module MongoidAbility
  describe 'basic ability Benchmark' do
    let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
    let(:owner) { MyRole.new(my_locks: [read_lock]) }
    let(:ability) { Ability.new(owner) }

    let(:default_locks) { [MyLock.new(action: :read, outcome: true)] }

    bench_performance_constant 'can?' do |n|
      MySubject.stub :default_locks, default_locks do
        n.times do
          ability.can?(:read, MySubject).must_equal false
        end
      end
    end

    bench_performance_constant 'cannot?' do |n|
      MySubject.stub :default_locks, default_locks do
        n.times do
          ability.cannot?(:read, MySubject).must_equal true
        end
      end
    end

    bench_performance_constant 'accessible_by' do |n|
      MySubject.stub :default_locks, default_locks do
        n.times do
          MySubject.accessible_by(ability, :read).must_be_kind_of Mongoid::Criteria
        end
      end
    end
  end
end
