# require 'test_helper'
#
# module MongoidAbility
#   describe 'syntactic sugar' do
#     let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
#     let(:owner) { MyRole.new(my_locks: [read_lock]) }
#     let(:ability) { Ability.new(owner) }
#     let(:options) { { x: 1 } }
#
#     let(:default_locks) { [MyLock.new(action: :read, outcome: true)] }
#
#     it 'owner can?' do
#       MySubject.stub :default_locks, default_locks do
#         [MySubject].select(&ability.can_read(options)).must_equal []
#         [MySubject].select(&ability.can_read?(options)).must_equal []
#
#         ability.can_read(MySubject, options).must_equal false
#         ability.can_read?(MySubject, options).must_equal false
#       end
#     end
#
#     it 'owner cannot?' do
#       MySubject.stub :default_locks, default_locks do
#         [MySubject].select(&ability.cannot_read(options)).must_equal [MySubject]
#         [MySubject].select(&ability.cannot_read?(options)).must_equal [MySubject]
#
#         ability.cannot_read(MySubject, options).must_equal true
#         ability.cannot_read?(MySubject, options).must_equal true
#       end
#     end
#   end
# end
