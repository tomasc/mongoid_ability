# require 'test_helper'
#
# module MongoidAbility
#   describe Subject do
#     let(:my_subject_default_locks) { [] }
#     let(:my_subject_1_default_locks) { [] }
#     let(:my_subject_2_default_locks) { [] }
#
#     describe '.default_lock' do
#       it 'stores them' do
#         MySubject.stub :default_locks, my_subject_default_locks do
#           MySubject1.stub :default_locks, my_subject_1_default_locks do
#             MySubject2.stub :default_locks, my_subject_2_default_locks do
#               MySubject.default_lock MyLock, :read, true
#               MySubject.default_lock MyLock, :update, true
#               MySubject1.default_lock MyLock1, :update, false
#
#               MySubject.default_locks.map(&:action).map(&:to_s).sort.must_equal %w(read update)
#               MySubject1.default_locks.map(&:action).map(&:to_s).sort.must_equal %w(update)
#             end
#           end
#         end
#       end
#     end
#
#     describe 'prevents conflicts' do
#       it 'does not allow multiple locks for same action' do
#         MySubject.stub :default_locks, my_subject_default_locks do
#           MySubject1.stub :default_locks, my_subject_1_default_locks do
#             MySubject2.stub :default_locks, my_subject_2_default_locks do
#               MySubject.default_lock MyLock1, :read, false
#               MySubject1.default_lock MyLock, :read, true
#
#               MySubject.default_locks.count { |l| l.action == :read }.must_equal 1
#             end
#           end
#         end
#       end
#
#       it 'replace existing locks with new attributes' do
#         MySubject.stub :default_locks, my_subject_default_locks do
#           MySubject1.stub :default_locks, my_subject_1_default_locks do
#             MySubject2.stub :default_locks, my_subject_2_default_locks do
#               MySubject.default_lock MyLock1, :read, false
#               MySubject1.default_lock MyLock, :read, true
#
#               MySubject.default_locks.detect { |l| l.action == :read }.outcome.must_equal false
#             end
#           end
#         end
#       end
#
#       it 'replaces existing locks with new one' do
#         MySubject.stub :default_locks, my_subject_default_locks do
#           MySubject1.stub :default_locks, my_subject_1_default_locks do
#             MySubject2.stub :default_locks, my_subject_2_default_locks do
#               MySubject.default_lock MyLock1, :read, false
#               MySubject1.default_lock MyLock, :read, true
#
#               MySubject.default_locks.detect { |l| l.action == :read }.class.must_equal MyLock1
#             end
#           end
#         end
#       end
#
#       it 'replaces superclass locks' do
#         MySubject.stub :default_locks, my_subject_default_locks do
#           MySubject1.stub :default_locks, my_subject_1_default_locks do
#             MySubject2.stub :default_locks, my_subject_2_default_locks do
#               MySubject.default_lock MyLock1, :read, false
#               MySubject1.default_lock MyLock, :read, true
#
#               MySubject1.default_locks.count.must_equal 1
#               MySubject1.default_locks.detect { |l| l.action == :read }.outcome.must_equal true
#             end
#           end
#         end
#       end
#     end
#
#     describe '.is_root_class?' do
#       it { MySubject.is_root_class?.must_equal true }
#       it { MySubject1.is_root_class?.must_equal false }
#       it { MySubject2.is_root_class?.must_equal false }
#     end
#
#     describe '.root_class' do
#       it { MySubject.root_class.must_equal MySubject }
#       it { MySubject1.root_class.must_equal MySubject }
#       it { MySubject2.root_class.must_equal MySubject }
#     end
#   end
# end
