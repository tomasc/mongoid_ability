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

        # describe 'closed id locks' do
        #   let(:role_1) { MyRole.new(my_locks: [MyLock.new(subject: my_subject, action: :update, outcome: false)]) }
        #   let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: true)] }
        #
        #   it 'applies id locks' do
        #     MySubject.stub :default_locks, my_subject_default_locks do
        #       MySubject1.stub :default_locks, my_subject_1_default_locks do
        #         MySubject2.stub :default_locks, my_subject_2_default_locks do
        #           MySubject.accessible_by(ability, :update).to_a.wont_include my_subject
        #           MySubject.accessible_by(ability, :update).to_a.must_include my_subject1
        #           MySubject.accessible_by(ability, :update).to_a.must_include my_subject2
        #         end
        #       end
        #     end
        #   end
        # end

        # describe 'open id locks' do
        #   let(:role_1) { MyRole.new(my_locks: [MyLock.new(subject: my_subject1, action: :update, outcome: true)]) }
        #   let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: false)] }
        #
        #   it 'applies id locks' do
        #     MySubject.stub :default_locks, my_subject_default_locks do
        #       MySubject1.stub :default_locks, my_subject_1_default_locks do
        #         MySubject2.stub :default_locks, my_subject_2_default_locks do
        #           MySubject.accessible_by(ability, :update).to_a.wont_include my_subject
        #           MySubject1.accessible_by(ability, :update).to_a.must_include my_subject1
        #           MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject2
        #         end
        #       end
        #     end
        #   end
        # end

        # describe 'prefix' do
        #   let(:prefix) { :subject }
        #   let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: true)] }
        #
        #   it 'allows to pass prefix' do
        #     MySubject.stub :default_locks, my_subject_default_locks do
        #       MySubject1.stub :default_locks, my_subject_1_default_locks do
        #         MySubject2.stub :default_locks, my_subject_2_default_locks do
        #           selector = MySubject.accessible_by(ability, :update, prefix: prefix).selector
        #           selector.must_equal('$and' => [{ '$or' => [{ "#{prefix}_type" => { '$nin' => [] } }, { "#{prefix}_type" => { '$in' => [] }, "#{prefix}_id" => { '$in' => [] } }] }, { "#{prefix}_id" => { '$nin' => [] } }])
        #         end
        #       end
        #     end
        #   end
        # end
      end
    end
  end
end
