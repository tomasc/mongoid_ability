require 'test_helper'

module MongoidAbility
  describe 'owner locks test' do
    subject { MySubject.new }

    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }

    describe 'when lock for subject' do
      let(:subject_lock) { MyLock.new(action: :read, subject: subject, outcome: false) }
      let(:owner) { MyOwner.new(my_locks: [subject_lock]) }

      before(:all) { MySubject.default_lock MyLock, :read, true }

      it { _(ability.can?(:read, subject.class)).must_equal true }
      it { _(ability.can?(:read, subject)).must_equal false }
    end

    describe 'when lock for subject type' do
      let(:subject_type_lock) { MyLock.new(action: :read, subject_type: subject.class, outcome: false) }
      let(:owner) { MyOwner.new(my_locks: [subject_type_lock]) }

      before(:all) { MySubject.default_lock MyLock, :read, true }

      it { _(ability.can?(:read, subject.class)).must_equal false }
      it { _(ability.can?(:read, subject)).must_equal false }
    end
  end
end
