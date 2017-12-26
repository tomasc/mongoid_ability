require 'test_helper'

module CanCan
  module ModelAdapters
    describe MongoidAdapter do
      describe '.accessible_by' do
        let(:my_subject) { MySubject.new }
        let(:my_subject1) { MySubject1.new }
        let(:my_subject2) { MySubject2.new }

        let(:role_1) { MyRole.new }
        let(:role_2) { MyRole.new }
        let(:owner) { MyOwner.new(my_roles: [role_1, role_2]) }
        let(:ability) { MongoidAbility::Ability.new(owner) }

        before do
          my_subject.save!
          my_subject1.save!
          my_subject2.save!
        end

        after(:all) do
          MySubject.default_locks = []
          MySubject1.default_locks = []
          MySubject2.default_locks = []
        end

        describe 'subject type locks' do
          describe 'default open locks' do
            before { MySubject.default_lock MyLock, :update, true }

            it { MySubject.accessible_by(ability, :update).to_a.must_include my_subject }
            it { MySubject.accessible_by(ability, :update).to_a.must_include my_subject1 }
            it { MySubject.accessible_by(ability, :update).to_a.must_include my_subject2 }

            it { MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject }
            it { MySubject1.accessible_by(ability, :update).to_a.must_include my_subject1 }
            it { MySubject1.accessible_by(ability, :update).to_a.must_include my_subject2 }

            it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject }
            it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject1 }
            it { MySubject2.accessible_by(ability, :update).to_a.must_include my_subject2 }
          end

          describe 'default closed locks' do
            before { MySubject.default_lock MyLock, :update, false }

            it { MySubject.accessible_by(ability, :update).to_a.wont_include my_subject }
            it { MySubject.accessible_by(ability, :update).to_a.wont_include my_subject1 }
            it { MySubject.accessible_by(ability, :update).to_a.wont_include my_subject2 }

            it { MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject }
            it { MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject1 }
            it { MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject2 }

            it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject }
            it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject1 }
            it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject2 }

            it { MySubject.accessible_by(ability, :update).selector.must_equal({}) }
          end

          describe 'default combined locks' do
            before(:all) do
              MySubject.default_lock MyLock, :update, false
              MySubject1.default_lock MyLock, :update, true
              MySubject2.default_lock MyLock, :update, false
            end

            it { MySubject.accessible_by(ability, :update).to_a.wont_include my_subject }
            it { MySubject.accessible_by(ability, :update).to_a.must_include my_subject1 }
            it { MySubject.accessible_by(ability, :update).to_a.wont_include my_subject2 }

            it { MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject }
            it { MySubject1.accessible_by(ability, :update).to_a.must_include my_subject1 }
            it { MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject2 }

            it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject }
            it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject1 }
            it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject2 }
          end
        end

        describe 'conditions locks' do
          describe 'subject locks' do
            describe 'closed id locks' do
              let(:lock) { MyLock.new(subject: my_subject, action: :update, outcome: false) }
              let(:role_1) { MyRole.new(my_locks: [lock]) }

              before(:all) do
                MySubject.default_lock MyLock, :update, true
              end

              it { MySubject.accessible_by(ability, :update).to_a.wont_include my_subject }
              it { MySubject.accessible_by(ability, :update).to_a.must_include my_subject1 }
              it { MySubject.accessible_by(ability, :update).to_a.must_include my_subject2 }
            end

            describe 'open id locks' do
              let(:lock) { MyLock.new(subject: my_subject1, action: :update, outcome: true) }
              let(:role_1) { MyRole.new(my_locks: [lock]) }

              before(:all) do
                MySubject.default_lock MyLock, :update, false
              end

              it { MySubject.accessible_by(ability, :update).to_a.wont_include my_subject }
              it { MySubject1.accessible_by(ability, :update).to_a.must_include my_subject1 }
              it { MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject2 }
            end

            describe 'closed types & open ids' do
              let(:lock_1) { MyLock.new(subject_type: MySubject, action: :update, outcome: false) }
              let(:lock_2) { MyLock.new(subject: my_subject, action: :update, outcome: true) }
              let(:lock_3) { MyLock.new(subject: my_subject1, action: :update, outcome: true) }

              let(:owner) { MyOwner.new(my_locks: [lock_1, lock_2, lock_3]) }

              it { MySubject.accessible_by(ability, :update).must_include my_subject }
              it { MySubject.accessible_by(ability, :update).must_include my_subject1 }
            end
          end

          describe 'arbitrary conditions' do
            describe 'positive' do
              let(:my_subject1) { MySubject1.new(override: true) }

              before(:all) { MySubject.default_lock MyLock, :update, true, override: true }

              it { MySubject.accessible_by(ability, :update).to_a.wont_include(my_subject) }
              it { MySubject.accessible_by(ability, :update).to_a.must_include(my_subject1) }
              it { MySubject.accessible_by(ability, :update).to_a.wont_include(my_subject2) }

              it { MySubject1.accessible_by(ability, :update).to_a.wont_include(my_subject) }
              it { MySubject1.accessible_by(ability, :update).to_a.must_include(my_subject1) }
              it { MySubject1.accessible_by(ability, :update).to_a.wont_include(my_subject2) }

              it { MySubject2.accessible_by(ability, :update).to_a.wont_include(my_subject) }
              it { MySubject2.accessible_by(ability, :update).to_a.wont_include(my_subject1) }
              it { MySubject2.accessible_by(ability, :update).to_a.wont_include(my_subject2) }
            end

            describe 'negative' do
              let(:my_subject1) { MySubject1.new(override: true) }

              before(:all) do
                MySubject.default_lock MyLock, :update, true
                MySubject.default_lock MyLock, :update, false, override: true
              end

              it { MySubject.accessible_by(ability, :update).to_a.must_include(my_subject) }
              it { MySubject.accessible_by(ability, :update).to_a.wont_include(my_subject1) }
              it { MySubject.accessible_by(ability, :update).to_a.must_include(my_subject2) }

              it { MySubject1.accessible_by(ability, :update).to_a.wont_include(my_subject) }
              it { MySubject1.accessible_by(ability, :update).to_a.wont_include(my_subject1) }
              it { MySubject1.accessible_by(ability, :update).to_a.must_include(my_subject2) }

              it { MySubject2.accessible_by(ability, :update).to_a.wont_include(my_subject) }
              it { MySubject2.accessible_by(ability, :update).to_a.wont_include(my_subject1) }
              it { MySubject2.accessible_by(ability, :update).to_a.must_include(my_subject2) }
            end
          end
        end

        describe 'prefix' do
          let(:lock_1) { MyLock.new(subject: my_subject1, action: :update, outcome: true) }
          let(:lock_2) { MyLock.new(subject: my_subject2, action: :update, outcome: false) }
          let(:role_1) { MyRole.new(my_locks: [lock_1, lock_2]) }

          let(:prefix) { :subject }
          let(:selector) { MySubject.accessible_by(ability, :update, prefix: prefix).selector }

          before(:all) do
            MySubject.default_lock MyLock, :update, true
          end

          it 'allows to pass prefix' do
            selector.must_equal(
              '$and' => [
                { '$or' => [
                  { 'subject_type' => { '$in' => [MySubject, MySubject1, MySubject2] } },
                  { 'subject_id' => my_subject1.id }
                ] },
                { 'subject_id' => { '$ne' => my_subject2.id } }
              ]
            )
          end
        end
      end
    end
  end
end
