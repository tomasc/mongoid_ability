require "test_helper"

module MongoidAbility
  describe AccessibleQueryBuilder do

    let(:base_class) { SubjectTest }
    
    let(:user) { TestUser.new }
    let(:ability) { Ability.new(user) }

    let(:action) { :read }

    subject { AccessibleQueryBuilder.call(base_class, ability, action) }

    it 'returns Mongoid::Criteria' do
      subject.must_be_kind_of Mongoid::Criteria
    end

  end
end