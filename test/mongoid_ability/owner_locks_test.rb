require 'test_helper'

module MongoidAbility
  describe 'owner locks test' do
    subject { MySubject.new }

    let(:subject_lock) { MyLock.new(action: :read, subject: subject, outcome: false) }
    let(:subject_type_lock) { MyLock.new(action: :read, subject_type: subject.class, outcome: false) }

    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }

    let(:default_locks) { [MyLock.new(subject_type: MySubject, action: :read, outcome: true)] }

    describe 'when lock for subject' do
      before { owner.my_locks = [subject_lock] }

      it 'applies it' do
        MySubject.stub :default_locks, default_locks do
          ability.can?(:read, subject.class).must_equal true
          ability.can?(:read, subject).must_equal false
        end
      end
    end

    describe 'when lock for subject type' do
      before { owner.my_locks = [subject_type_lock] }

      it 'applies it' do
        MySubject.stub :default_locks, default_locks do
          ability.can?(:read, subject.class).must_equal false
          ability.can?(:read, subject).must_equal false
        end
      end
    end
  end
end
