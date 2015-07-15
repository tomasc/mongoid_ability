require 'test_helper'

module MongoidAbility
  describe 'owner locks test' do
    subject { MySubject.new }

    let(:subject_type_lock) { MyLock.new(action: :read, subject_type: subject.class.to_s, outcome: false) }
    let(:subject_lock) { MyLock.new(action: :read, subject: subject, outcome: false) }

    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }

    describe 'when lock for subject' do
      before { owner.locks = [subject_lock] }
      it '' do
        ability.can?(:read, subject).must_equal false
        ability.can?(:read, subject.class).must_equal true
      end
    end

    # describe 'when lock for subject_type' do
    #   before { owner.locks = [subject_type_lock] }
    #   it { ability.can?(:read, subject).must_equal false }
    #   it { ability.can?(:read, subject.class.to_s).must_equal true }
    # end
    #
    # describe 'when no lock' do
    #   it { ability.can?(:read, subject).must_equal true }
    #   it { ability.can?(:read, subject.class.to_s).must_equal true }
    # end
  end
end
