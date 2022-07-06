require 'test_helper'

module MongoidAbility
  describe 'basic ability test' do
    let(:owner) { MyRole.new }
    let(:ability) { Ability.new(owner) }

    describe 'default' do
      it { _(ability.can?(:read, MySubject)).must_equal false }
      it { _(ability.cannot?(:read, MySubject)).must_equal true }
    end

    describe 'class locks' do
      before(:all) { MySubject.default_lock MyLock, :read, true }

      it { _(ability.can?(:read, MySubject)).must_equal true }
      it { _(ability.cannot?(:read, MySubject)).must_equal false }
    end

    describe 'inherited locks' do
      describe 'subject_type' do
        let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
        let(:my_role) { MyRole.new(my_locks: [read_lock]) }
        let(:owner) { MyOwner.new(my_roles: [my_role]) }

        it { _(ability.can?(:read, MySubject)).must_equal true }
        it { _(ability.cannot?(:read, MySubject)).must_equal false }
      end

      describe 'subject_id' do
        let(:my_subject) { MySubject.new }
        let(:read_lock) { MyLock.new(subject: my_subject, action: :read, outcome: true) }
        let(:my_role) { MyRole.new(my_locks: [read_lock]) }
        let(:owner) { MyOwner.new(my_roles: [my_role]) }

        it { _(ability.can?(:read, my_subject)).must_equal true }
        it { _(ability.cannot?(:read, my_subject)).must_equal false }

        describe 'when id stored as String' do
          let(:read_lock) { MyLock.new(subject_type: my_subject.model_name.to_s, subject_id: my_subject.id.to_s, action: :read, outcome: true) }

          it { _(ability.can?(:read, my_subject)).must_equal true }
          it { _(ability.cannot?(:read, my_subject)).must_equal false }
        end
      end
    end

    describe 'owner locks' do
      describe 'subject_type' do
        let(:read_lock) { MyLock.new(subject_type: MySubject, action: :read, outcome: true) }
        let(:owner) { MyOwner.new(my_locks: [read_lock]) }

        it { _(ability.can?(:read, MySubject)).must_equal true }
        it { _(ability.cannot?(:read, MySubject)).must_equal false }
      end

      describe 'subject_id' do
        let(:my_subject) { MySubject.new }
        let(:read_lock) { MyLock.new(subject: my_subject, action: :read, outcome: true) }
        let(:owner) { MyOwner.new(my_locks: [read_lock]) }

        it { _(ability.can?(:read, my_subject)).must_equal true }
        it { _(ability.cannot?(:read, my_subject)).must_equal false }
      end
    end
  end
end
