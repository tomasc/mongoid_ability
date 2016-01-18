require 'test_helper'

module MongoidAbility
  describe AccessibleQueryBuilder do
    let(:base_class) { MySubject }
    let(:owner) { MyOwner.new }
    let(:ability) { Ability.new(owner) }
    let(:action) { :read }
    let(:options) { Hash.new }

    subject { AccessibleQueryBuilder.call(base_class, ability, action, options) }

    it 'returns Mongoid::Criteria' do
      subject.must_be_kind_of Mongoid::Criteria
    end
  end
end
