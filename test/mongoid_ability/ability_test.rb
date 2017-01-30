require 'test_helper'

module MongoidAbility
  describe Ability do
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }

    let(:my_subject_default_locks) { [] }
    let(:my_subject_1_default_locks) { [] }
    let(:my_subject_2_default_locks) { [] }

    it 'exposes owner' do
      ability.owner.must_equal owner
    end

    describe 'default locks' do
      # NOTE: we might need to use the .default_lock macro in case we propagate down directly
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :update, outcome: true)] }

      it 'propagates from superclass to all subclasses' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              ability.can?(:update, MySubject).must_equal true
              ability.can?(:update, MySubject1).must_equal true
              ability.can?(:update, MySubject2).must_equal true
            end
          end
        end
      end
    end

    describe 'when defined for all superclasses' do
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: false)] }
      let(:my_subject_1_default_locks) { [MyLock.new(subject_type: MySubject1, action: :read, outcome: true)] }
      let(:my_subject_2_default_locks) { [MyLock.new(subject_type: MySubject2, action: :read, outcome: false)] }

      it 'respects the definitions' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              ability.can?(:read, MySubject).must_equal false
              ability.can?(:read, MySubject1).must_equal true
              ability.can?(:read, MySubject2).must_equal false
            end
          end
        end
      end
    end

    describe 'when defined for some superclasses' do
      let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: false)] }
      let(:my_subject_2_default_locks) { [MyLock.new(subject_type: MySubject2, action: :read, outcome: true)] }

      it 'propagates default locks to subclasses' do
        MySubject.stub :default_locks, my_subject_default_locks do
          MySubject1.stub :default_locks, my_subject_1_default_locks do
            MySubject2.stub :default_locks, my_subject_2_default_locks do
              ability.can?(:read, MySubject).must_equal false
              ability.can?(:read, MySubject1).must_equal false
              ability.can?(:read, MySubject2).must_equal true
            end
          end
        end
      end
    end

    # ---------------------------------------------------------------------

    describe 'user locks' do
      describe 'when defined for superclass' do
        let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: false)] }

        before do
          owner.my_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]
        end

        it 'applies the superclass lock' do
          MySubject.stub :default_locks, my_subject_default_locks do
            MySubject1.stub :default_locks, my_subject_1_default_locks do
              MySubject2.stub :default_locks, my_subject_2_default_locks do
                ability.can?(:read, MySubject2).must_equal true
              end
            end
          end
        end
      end
    end

    # ---------------------------------------------------------------------

    describe 'inherited owner locks' do
      describe 'when multiple inherited owners' do
        let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: false)] }

        before do
          owner.my_roles = [
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]),
            MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: false)])
          ]
        end

        it 'prefers positive outcome' do
          MySubject.stub :default_locks, my_subject_default_locks do
            MySubject1.stub :default_locks, my_subject_1_default_locks do
              MySubject2.stub :default_locks, my_subject_2_default_locks do
                ability.can?(:read, MySubject).must_equal true
              end
            end
          end
        end
      end

      describe 'when defined for superclass' do
        let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: false)] }

        before do
          owner.my_roles = [MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)])]
        end

        it 'applies the superclass lock' do
          MySubject.stub :default_locks, my_subject_default_locks do
            MySubject1.stub :default_locks, my_subject_1_default_locks do
              MySubject2.stub :default_locks, my_subject_2_default_locks do
                ability.can?(:read, MySubject2).must_equal true
              end
            end
          end
        end
      end
    end

    # ---------------------------------------------------------------------

    describe 'combined locks' do
      describe 'user and role locks' do
        let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: false)] }

        before do
          owner.my_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
          owner.my_roles = [MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)])]
        end

        it 'prefers user locks' do
          MySubject.stub :default_locks, my_subject_default_locks do
            MySubject1.stub :default_locks, my_subject_1_default_locks do
              MySubject2.stub :default_locks, my_subject_2_default_locks do
                ability.can?(:read, MySubject).must_equal false
              end
            end
          end
        end
      end

      describe 'roles and default locks' do
        let(:my_subject_default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: false)] }

        before do
          owner.my_roles = [MyRole.new(my_locks: [MyLock.new(subject_type: MySubject, action: :read, outcome: true)])]
        end

        it 'prefers role locks' do
          MySubject.stub :default_locks, my_subject_default_locks do
            MySubject1.stub :default_locks, my_subject_1_default_locks do
              MySubject2.stub :default_locks, my_subject_2_default_locks do
                ability.can?(:read, MySubject).must_equal true
              end
            end
          end
        end
      end
    end
  end
end
