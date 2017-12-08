# require 'test_helper'
#
# module MongoidAbility
#   describe ResolveDefaultLocks do
#     describe '.call' do
#       let(:options) { {} }
#
#       let(:my_subject_default_locks) do
#         [
#           MyLock.new(subject_type: MySubject, action: :read, outcome: true),
#           MyLock.new(subject_type: MySubject, action: :update, outcome: false)
#         ]
#       end
#
#       let(:my_subject_1_default_locks) do
#         [
#           MyLock.new(subject_type: MySubject1, action: :read, outcome: false),
#           MyLock.new(subject_type: MySubject1, action: :update, outcome: true)
#         ]
#       end
#
#       it 'resolves on self' do
#         MySubject.stub :default_locks, my_subject_default_locks do
#           MySubject1.stub :default_locks, my_subject_1_default_locks do
#             ResolveDefaultLocks.call(nil, :read, MySubject, nil, options).must_equal MySubject.default_locks.first
#             ResolveDefaultLocks.call(nil, :update, MySubject, nil, options).must_equal MySubject.default_locks.last
#           end
#         end
#       end
#
#       it 'resolves on subclass' do
#         MySubject.stub :default_locks, my_subject_default_locks do
#           MySubject1.stub :default_locks, my_subject_1_default_locks do
#             ResolveDefaultLocks.call(nil, :read, MySubject1, nil, options).must_equal MySubject1.default_locks.first
#             ResolveDefaultLocks.call(nil, :update, MySubject1, nil, options).must_equal MySubject1.default_locks.last
#           end
#         end
#       end
#     end
#   end
# end
