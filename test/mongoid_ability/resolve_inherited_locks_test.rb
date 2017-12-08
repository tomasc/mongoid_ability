# require 'test_helper'
#
# module MongoidAbility
#   describe ResolveInheritedLocks do
#     describe 'when defined on class' do
#       let(:owner) { MyOwner.new }
#       let(:my_subject) { MySubject.new }
#
#       let(:default_locks) { [MyLock.new(subject_type: MySubject, action: :my_read, outcome: true)] }
#
#       it 'returns it' do
#         MySubject.stub :default_locks, default_locks do
#           ResolveInheritedLocks.call(owner, :my_read, MySubject, nil).calculated_outcome.must_equal true
#           ResolveInheritedLocks.call(owner, :my_read, MySubject, my_subject).calculated_outcome.must_equal true
#         end
#       end
#
#       describe 'when defined on one of the inherited owners' do
#         let(:inherited_owner_1) { MyOwner.new }
#         let(:inherited_owner_2) { MyOwner.new }
#         let(:owner) { MyOwner.new(my_roles: [inherited_owner_1, inherited_owner_2]) }
#         let(:my_subject) { MySubject.new }
#
#         let(:lock) { MyLock.new(action: :my_read, subject_type: MySubject, outcome: false) }
#
#         before { inherited_owner_1.my_locks = [lock] }
#
#         it 'returns it' do
#           MySubject.stub :default_locks, default_locks do
#             ResolveInheritedLocks.call(owner, :my_read, MySubject, nil).must_equal lock
#             ResolveInheritedLocks.call(owner, :my_read, MySubject, my_subject.id).must_equal lock
#           end
#         end
#
#         describe 'when defined on user' do
#           let(:lock) { MyLock.new(action: :my_read, subject_type: MySubject, outcome: false) }
#
#           before { owner.my_locks = [lock] }
#
#           it 'returns it' do
#             MySubject.stub :default_locks, default_locks do
#               ResolveInheritedLocks.call(owner, :my_read, MySubject, nil).must_equal lock
#               ResolveInheritedLocks.call(owner, :my_read, MySubject, my_subject.id).must_equal lock
#             end
#           end
#         end
#       end
#     end
#   end
# end
