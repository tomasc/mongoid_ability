# require 'test_helper'
#
# module MongoidAbility
#   describe ResolveOwnerLocks do
#     let(:owner) { MyOwner.new }
#     let(:my_subject) { MySubject.new }
#
#     subject { ResolveOwnerLocks.call(owner, :read, MySubject, nil) }
#     let(:resolver_for_subject_id) { ResolveOwnerLocks.call(owner, :read, MySubject, my_subject.id) }
#     let(:default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: false)] }
#
#     describe '#lock' do
#       describe 'no locks' do
#         it 'must be nil' do
#           MySubject.stub :default_locks, default_locks do
#             subject.must_be_nil
#           end
#         end
#       end
#
#       describe 'id locks' do
#         it 'returns outcome' do
#           MySubject.stub :default_locks, default_locks do
#             owner.my_locks = [MyLock.new(action: :read, subject: my_subject, outcome: true)]
#             resolver_for_subject_id.calculated_outcome.must_equal true
#           end
#         end
#
#         it 'prefers negative outcome' do
#           MySubject.stub :default_locks, default_locks do
#             owner.my_locks = [MyLock.new(action: :read, subject: my_subject, outcome: true),
#                               MyLock.new(action: :read, subject: my_subject, outcome: false)]
#             resolver_for_subject_id.calculated_outcome.must_equal false
#           end
#         end
#       end
#
#       describe 'class locks' do
#         it 'returns outcome' do
#           MySubject.stub :default_locks, default_locks do
#             owner.my_locks = [MyLock.new(action: :read, subject_type: MySubject, outcome: true)]
#             subject.calculated_outcome.must_equal true
#           end
#         end
#
#         it 'prefers negative outcome' do
#           MySubject.stub :default_locks, default_locks do
#             owner.my_locks = [MyLock.new(action: :read, subject_type: MySubject, outcome: true),
#                               MyLock.new(action: :read, subject_type: MySubject, outcome: false)]
#             subject.calculated_outcome.must_equal false
#           end
#         end
#       end
#     end
#   end
# end
