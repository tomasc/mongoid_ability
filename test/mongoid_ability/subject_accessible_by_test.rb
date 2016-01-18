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

    # =====================================================================

    describe 'default open locks' do
      before do
        # NOTE: we might need to use the .default_lock macro in case we propagate down directly
        MySubject.default_locks = [ MyLock.new(subject_type: MySubject, action: :update, outcome: true) ]
        MySubject1.default_locks = []
        MySubject2.default_locks = []

        my_subject
        my_subject1
        my_subject2
      end

      it 'propagates from superclass to all subclasses' do
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

    describe 'default closed locks' do
      before do
        # NOTE: we might need to use the .default_lock macro in case we propagate down directly
        MySubject.default_locks = [ MyLock.new(subject_type: MySubject, action: :update, outcome: false) ]
        MySubject1.default_locks = []
        MySubject2.default_locks = []

        my_subject
        my_subject1
        my_subject2
      end

      it 'propagates from superclass to all subclasses' do
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

    describe 'default combined locks' do
      before do
        # NOTE: we might need to use the .default_lock macro in case we propagate down directly
        MySubject.default_locks = [ MyLock.new(subject_type: MySubject, action: :update, outcome: false) ]
        MySubject1.default_locks = [ MyLock.new(subject_type: MySubject, action: :update, outcome: true) ]
        MySubject2.default_locks = [ MyLock.new(subject_type: MySubject, action: :update, outcome: false) ]

        my_subject
        my_subject1
        my_subject2
      end

      it 'propagates from superclass to all subclasses' do
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

    # ---------------------------------------------------------------------

    describe 'closed id locks' do
      let(:role_1) { MyRole.new(my_locks: [ MyLock.new(subject: my_subject, action: :update, outcome: false) ]) }

      before do
        MySubject.default_locks = [ MyLock.new(subject_type: MySubject, action: :update, outcome: true) ]
        MySubject1.default_locks = []
        MySubject2.default_locks = []

        my_subject
        my_subject1
        my_subject2
      end

      it 'applies id locks' do
        MySubject.accessible_by(ability, :update).to_a.wont_include my_subject
        MySubject.accessible_by(ability, :update).to_a.must_include my_subject1
        MySubject.accessible_by(ability, :update).to_a.must_include my_subject2
      end
    end

    describe 'open id locks' do
      let(:role_1) { MyRole.new(my_locks: [ MyLock.new(subject: my_subject1, action: :update, outcome: true) ]) }

      before do
        MySubject.default_locks = [ MyLock.new(subject_type: MySubject, action: :update, outcome: false) ]
        MySubject1.default_locks = []
        MySubject2.default_locks = []

        my_subject
        my_subject1
        my_subject2
      end

      it 'applies id locks' do
        MySubject.accessible_by(ability, :update).to_a.wont_include my_subject
        MySubject1.accessible_by(ability, :update).to_a.must_include my_subject1
        MySubject2.accessible_by(ability, :update).to_a.wont_include my_subject2
      end
    end
  end
end
