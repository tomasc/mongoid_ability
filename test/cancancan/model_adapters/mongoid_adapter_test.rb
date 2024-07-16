require 'test_helper'

module CanCan
  module ModelAdapters
    describe MongoidAdapter do
      describe '.accessible_by' do
        let(:my_subject) { MySubject.new }
        let(:my_subject1) { MySubject1.new }
        let(:my_subject11) { MySubject11.new }
        let(:my_subject2) { MySubject2.new }
        let(:my_subject21) { MySubject21.new }

        let(:role_1) { MyRole.new }
        let(:role_2) { MyRole.new }
        let(:owner) { MyOwner.new(my_roles: [role_1, role_2]) }
        let(:ability) { MongoidAbility::Ability.new(owner) }

        before do
          my_subject.save!
          my_subject1.save!
          my_subject11.save!
          my_subject2.save!
          my_subject21.save!
        end

        it "works with superclass locks of multiple types" do
          MySubject.default_lock MyLock, :read, true

          new_subject = MySubject.create!
          another_subject = MySubject.create!
          lock1 = MyLock.new(subject: new_subject, action: :read, outcome: true)
          lock2 = MyLock.new(subject: another_subject, action: :read, outcome: false)
          new_role = MyRole.create!(my_locks: [lock1, lock2])
          new_owner = MyOwner.create!(my_roles: [new_role])
          new_ability = MongoidAbility::Ability.new(new_owner)
          final_subject = MySubject1.create!

          _(MySubject1.accessible_by(new_ability, :read).to_a).must_include final_subject
        end

        describe 'subject type locks' do
          describe 'default open locks' do
            before do
              MySubject.default_lock MyLock, :read, true
            end

            it { _(MySubject.accessible_by(ability, :read).to_a).must_include my_subject }
            it { _(MySubject.accessible_by(ability, :read).to_a).must_include my_subject1 }
            it { _(MySubject.accessible_by(ability, :read).to_a).must_include my_subject2 }

            it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include my_subject }
            it { _(MySubject1.accessible_by(ability, :read).to_a).must_include my_subject1 }
            it { _(MySubject1.accessible_by(ability, :read).to_a).must_include my_subject2 }

            it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include my_subject }
            it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include my_subject1 }
            it { _(MySubject2.accessible_by(ability, :read).to_a).must_include my_subject2 }

            it 'works for unlocked non sci classes' do
              MyFlatSubject.default_lock MyLock, :read, true
              flat_subject = MyFlatSubject.create!

              _(MyFlatSubject.accessible_by(ability, :read).to_a)
                .must_include flat_subject
            end

            it 'works for locked non sci classes' do
              MyFlatSubject.default_lock MyLock, :read, false
              flat_subject = MyFlatSubject.create!

              _(MyFlatSubject.accessible_by(ability, :read).to_a)
                .wont_include flat_subject
            end
          end

          describe 'default closed locks' do
            before { MySubject.default_lock MyLock, :read, false }

            it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject }
            it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject1 }
            it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject2 }

            it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include my_subject }
            it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include my_subject1 }
            it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include my_subject2 }

            it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include my_subject }
            it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include my_subject1 }
            it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include my_subject2 }

            it { _(MySubject.accessible_by(ability, :read).selector).must_equal({}) }
          end

          describe 'default combined locks' do
            before(:all) do
              MySubject.default_lock MyLock, :read, false
              MySubject1.default_lock MyLock, :read, true
              MySubject2.default_lock MyLock, :read, false
            end

            it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject }
            it { _(MySubject.accessible_by(ability, :read).to_a).must_include my_subject1 }
            it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject2 }

            it { _(MySubject1.accessible_by(ability, :read).to_a).must_include my_subject1 }
            it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include my_subject2 }

            it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include my_subject2 }
          end

          describe 'combined locks' do
            before(:all) do
              MySubject.default_lock MyLock, :read, true
            end

            let(:lock) { MyLock.new(subject_type: MySubject1, action: :read, outcome: false) }
            let(:role) { MyRole.new(my_locks: [lock]) }
            let(:owner) { MyOwner.new(my_roles: [role]) }

            it { _(MySubject.accessible_by(ability, :read).to_a).must_include my_subject }
            it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject1 }
            it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject2 }

            it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include my_subject1 }
            it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include my_subject2 }

            it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include my_subject2 }
          end
        end

        describe 'conditions locks' do
          describe 'subject locks' do
            describe 'closed id locks' do
              let(:lock) { MyLock.new(subject: my_subject, action: :read, outcome: false) }
              let(:role_1) { MyRole.new(my_locks: [lock]) }

              before(:all) do
                MySubject.default_lock MyLock, :read, true
              end

              it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject }
              it { _(MySubject.accessible_by(ability, :read).to_a).must_include my_subject1 }
              it { _(MySubject.accessible_by(ability, :read).to_a).must_include my_subject2 }
            end

            describe 'open id locks' do
              let(:lock) { MyLock.new(subject: my_subject1, action: :read, outcome: true) }
              let(:role_1) { MyRole.new(my_locks: [lock]) }

              before(:all) do
                MySubject.default_lock MyLock, :read, false
              end

              it { _(MySubject.accessible_by(ability, :read).to_a).wont_include my_subject }
              it { _(MySubject1.accessible_by(ability, :read).to_a).must_include my_subject1 }
              it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include my_subject2 }
            end

            describe 'closed types & open ids' do
              let(:lock_1) { MyLock.new(subject_type: MySubject, action: :read, outcome: false) }
              let(:lock_2) { MyLock.new(subject: my_subject, action: :read, outcome: true) }
              let(:lock_3) { MyLock.new(subject: my_subject1, action: :read, outcome: true) }
              let(:lock_4) { MyLock.new(subject_type: MySubject2, action: :read, outcome: true) }

              let(:owner) { MyOwner.new(my_locks: [lock_1, lock_2, lock_3, lock_4]) }

              it { _(MySubject.accessible_by(ability, :read)).must_include my_subject }
              it { _(MySubject.accessible_by(ability, :read)).must_include my_subject1 }
              it { _(MySubject2.accessible_by(ability, :read)).must_include my_subject2 }
            end
          end

          describe 'arbitrary conditions' do
            describe 'positive' do
              let(:my_subject1) { MySubject1.new(override: true) }

              before(:all) do
                MySubject.default_lock MyLock, :read, true, override: true
              end

              it { _(MySubject.accessible_by(ability, :read).to_a).wont_include(my_subject) }
              it { _(MySubject.accessible_by(ability, :read).to_a).must_include(my_subject1) }
              it { _(MySubject.accessible_by(ability, :read).to_a).wont_include(my_subject2) }

              it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include(my_subject) }
              it { _(MySubject1.accessible_by(ability, :read).to_a).must_include(my_subject1) }
              it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include(my_subject2) }

              it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include(my_subject) }
              it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include(my_subject1) }
              it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include(my_subject2) }
            end

            describe 'negative' do
              let(:my_subject1) { MySubject1.new(override: true) }

              before(:all) do
                MySubject.default_lock MyLock, :read, true
                MySubject.default_lock MyLock, :read, false, override: true
              end

              it { _(MySubject.accessible_by(ability, :read).to_a).must_include(my_subject) }
              it { _(MySubject.accessible_by(ability, :read).to_a).wont_include(my_subject1) }
              it { _(MySubject.accessible_by(ability, :read).to_a).must_include(my_subject2) }

              it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include(my_subject) }
              it { _(MySubject1.accessible_by(ability, :read).to_a).wont_include(my_subject1) }
              it { _(MySubject1.accessible_by(ability, :read).to_a).must_include(my_subject2) }

              it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include(my_subject) }
              it { _(MySubject2.accessible_by(ability, :read).to_a).wont_include(my_subject1) }
              it { _(MySubject2.accessible_by(ability, :read).to_a).must_include(my_subject2) }
            end
          end
        end

        describe 'prefix' do
          let(:lock_1) { MyLock.new(subject: my_subject1, action: :read, outcome: true) }
          let(:lock_2) { MyLock.new(subject: my_subject2, action: :read, outcome: false) }
          let(:role_1) { MyRole.new(my_locks: [lock_1, lock_2]) }

          before(:all) do
            MySubject.default_lock MyLock, :read, true
          end

          it 'allows to pass prefix' do
            prefix = :subject
            selector = MySubject.accessible_by(ability, :read, prefix: prefix).selector

            _(selector).must_equal(
              {
                '$or' => [
                  { 'subject_id' => my_subject1.id },
                ],
                '$and' =>[
                  { 'subject_id'=> { '$nin' => [my_subject2.id] } }
                ]
              }
            )
          end
        end
      end
    end
  end
end
