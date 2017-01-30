require 'test_helper'

module MongoidAbility
  describe '.accessible_by' do
    let(:my_subject) { MySubject.create! }
    let(:my_subject1) { MySubject1.create! }
    let(:my_subject2) { MySubject2.create! }

    let(:role_1) { MyRole.new }
    let(:role_2) { MyRole.new }
    let(:owner) { MyOwner.new(my_roles: [role_1, role_2]) }
    let(:ability) { Ability.new(owner) }

    let(:my_subject_default_locks) { [] }
    let(:my_subject_1_default_locks) { [] }
    let(:my_subject_2_default_locks) { [] }

    before { my_subject; my_subject1; my_subject2 }

    describe 'default open locks' do
      # NOTE: we might need to use the .default_lock macro in case we propagate down directly
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: true)] }

      it 'propagates from superclass to all subclasses' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              MySubject.accessible_by(ability, :update).to_a.must_include my_subject
              MySubject.accessible_by(ability, :update).to_a.must_include my_subject1
              MySubject.accessible_by(ability, :update).to_a.must_include my_subject2

              MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject1.accessible_by(ability, :update).to_a.must_include my_subject1
              MySubject1.accessible_by(ability, :update).to_a.must_include my_subject2

              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject1
              MySubject2.accessible_by(ability, :update).to_a.must_include my_subject2
            end
          end
        end
      end
    end

    describe 'default closed locks' do
      # NOTE: we might need to use the .default_lock macro in case we propagate down directly
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: false)] }

      it 'propagates from superclass to all subclasses' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              MySubject.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject.accessible_by(ability, :update).to_a.wont_include my_subject1
              MySubject.accessible_by(ability, :update).to_a.wont_include my_subject2

              MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject1
              MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject2

              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject1
              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject2
            end
          end
        end
      end
    end

    describe 'default combined locks' do
      # NOTE: we might need to use the .default_lock macro in case we propagate down directly
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: false)] }
      let(:my_subject_1_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: true)] }
      let(:my_subject_2_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: false)] }

      it 'propagates from superclass to all subclasses' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              MySubject.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject.accessible_by(ability, :update).to_a.must_include my_subject1
              MySubject.accessible_by(ability, :update).to_a.wont_include my_subject2

              MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject1.accessible_by(ability, :update).to_a.must_include my_subject1
              MySubject1.accessible_by(ability, :update).to_a.wont_include my_subject2

              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject1
              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject2
            end
          end
        end
      end
    end

    describe 'closed id locks' do
      let(:role_1) { MyRole.new(my_locks: [MyLock.new(subject: my_subject, action: :update, outcome: false)]) }
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: true)] }

      it 'applies id locks' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              MySubject.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject.accessible_by(ability, :update).to_a.must_include my_subject1
              MySubject.accessible_by(ability, :update).to_a.must_include my_subject2
            end
          end
        end
      end
    end

    describe 'open id locks' do
      let(:role_1) { MyRole.new(my_locks: [MyLock.new(subject: my_subject1, action: :update, outcome: true)]) }
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: false)] }

      it 'applies id locks' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              MySubject.accessible_by(ability, :update).to_a.wont_include my_subject
              MySubject1.accessible_by(ability, :update).to_a.must_include my_subject1
              MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject2
            end
          end
        end
      end
    end

    describe 'prefix' do
      let(:prefix) { :subject }
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: true)] }

      it 'allows to pass prefix' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              selector = MySubject.accessible_by(ability, :update, prefix: prefix).selector
              selector.must_equal('$and' => [{ '$or' => [{ "#{prefix}_type" => { '$nin' => [] } }, { "#{prefix}_type" => { '$in' => [] }, "#{prefix}_id" => { '$in' => [] } }] }, { "#{prefix}_id" => { '$nin' => [] } }])
            end
          end
        end
      end
    end
  end
end
