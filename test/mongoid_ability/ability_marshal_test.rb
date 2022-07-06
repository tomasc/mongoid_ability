require 'test_helper'

module MongoidAbility
  describe 'marshal' do
    before(:all) { MySubject.default_lock MyLock, :read, true }

    let(:my_subject) { MySubject.new }
    let(:read_lock) { MyLock.new(subject_type: my_subject.model_name.to_s, subject_id: my_subject.id.to_s, action: :update, outcome: false) }
    let(:owner) { MyRole.new(my_locks: [read_lock]) }
    let(:ability) { Ability.new(owner) }

    let(:ability_dump) { Marshal.dump(ability) }
    let(:ability_load) { Marshal.load(ability_dump) }

    let(:loaded_rules) { ability_load.send(:rules) }

    describe 'dump' do
      it { _(ability_dump).must_be :present? }
    end

    describe 'load' do
      # TODO: improvement might be to add a description to this test, as the 2
      # integer is a bit magic
      it 'loads rules for each ?' do
        _(loaded_rules.count { |rule| rule.subjects == [MySubject] }).must_equal 2
      end

      it 'builds conditions for the subjects id' do
        _(loaded_rules.map(&:conditions)).must_include({ id: my_subject.id })
      end
    end
  end
end
