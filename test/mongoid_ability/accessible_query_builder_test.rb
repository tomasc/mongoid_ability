require 'test_helper'

module MongoidAbility
  describe AccessibleQueryBuilder do
    let(:base_class) { MySubject }
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }
    let(:action) { :read }
    let(:options) { Hash.new }

    before do
      MySubject.default_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: true)]
    end

    subject { AccessibleQueryBuilder.call(base_class, ability, action, options) }

    it 'returns Mongoid::Criteria' do
      subject.must_be_kind_of Mongoid::Criteria
    end

    it 'allows to pass prefix' do
      skip 'not sure how to best test this'
      selector = AccessibleQueryBuilder.call(base_class, ability, action, prefix: :foo).selector
    end

    # ---------------------------------------------------------------------

    describe 'closed_types' do
      let(:my_subject) { MySubject.create! }
      let(:my_subject_1) { MySubject1.create! }

      before do
        my_subject; my_subject_1
        owner.my_locks = [MyLock.new(subject_type: MySubject, action: :read, outcome: false)]
      end

      it 'does not return subject with that id' do
        MySubject.accessible_by(ability, :read).wont_include my_subject
        MySubject.accessible_by(ability, :read).wont_include my_subject_1
        MySubject1.accessible_by(ability, :read).wont_include my_subject_1
      end
    end

    describe 'closed_ids' do
      let(:my_subject_a) { MySubject.create! }
      let(:my_subject_b) { MySubject.create! }

      before do
        my_subject_a; my_subject_b
        owner.my_locks = [MyLock.new(subject: my_subject_a, action: :read, outcome: false)]
      end

      it 'does not return subject with that id' do
        MySubject.accessible_by(ability, :read).wont_include my_subject_a
        MySubject.accessible_by(ability, :read).must_include my_subject_b
      end
    end

    describe 'closed_types & open_ids' do
      let(:my_subject) { MySubject.create! }
      let(:my_subject_1) { MySubject1.create! }

      before do
        owner.my_locks = [
          MyLock.new(subject_type: MySubject, action: :read, outcome: false),
          MyLock.new(subject: my_subject, action: :read, outcome: true),
          MyLock.new(subject: my_subject_1, action: :read, outcome: true)
        ]
      end

      it 'does not return subject with that id' do
        MySubject.accessible_by(ability, :read).must_include my_subject
        MySubject.accessible_by(ability, :read).must_include my_subject_1
      end
    end
  end
end
