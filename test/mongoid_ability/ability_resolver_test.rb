require "test_helper"
  
module MongoidAbility
  describe AbilityResolver do

    let(:user) { TestUser.new }
    let(:role_editor) { TestRole.new(name: 'Editor') }
    let(:role_sysop) { TestRole.new(name: 'SysOp') }

    let(:ability_resolver_subject) { TestAbilityResolverSubject.new }
    
    subject { AbilityResolver.new(user, :read, TestAbilityResolverSubject.to_s) }
    let(:subject_with_id) { AbilityResolver.new(user, :read, TestAbilityResolverSubject.to_s, ability_resolver_subject) }

    # ---------------------------------------------------------------------
    
    describe 'errors' do
      it 'raises NameError for invalid subject_type' do
        -> { ar = AbilityResolver.new(user, :read, 'Foo') }.must_raise NameError
      end

      it 'raises StandardError when subject_type does not have default_locks' do
        -> { ar = AbilityResolver.new(user, :read, Object.to_s) }.must_raise StandardError
      end

      it 'raises StandardError when subject_type class or its ancestors does not have default_lock' do
        TestAbilityResolverSubject.stub(:default_locks, []) do
          -> { ar = AbilityResolver.new(user, :read, TestAbilityResolverSubject.to_s) }.must_raise StandardError
        end
      end
    end

    # ---------------------------------------------------------------------

    describe '#outcome' do
      describe 'no locks' do
        it 'returns nil if no locks for subject_type and action exists' do
          subject.outcome.must_be_nil
        end
      end

      describe 'id locks' do
        it 'returns outcome' do
          user.test_locks = [
            TestLock.new(action: :read, subject: ability_resolver_subject, outcome: true)
          ]
          subject_with_id.outcome.must_equal true
        end

        it 'prefers negative outcome' do
          user.test_locks = [
            TestLock.new(action: :read, subject: ability_resolver_subject, outcome: true),
            TestLock.new(action: :read, subject: ability_resolver_subject, outcome: false)
          ]
          subject_with_id.outcome.must_equal false
        end
      end

      describe 'class locks' do
        it 'returns outcome' do
          user.test_locks = [
            TestLock.new(action: :read, subject_type: TestAbilityResolverSubject.to_s, outcome: true)
          ]
          subject.outcome.must_equal true
        end

        it 'prefers negative outcome' do
          user.test_locks = [
            TestLock.new(action: :read, subject_type: TestAbilityResolverSubject.to_s, outcome: true),
            TestLock.new(action: :read, subject_type: TestAbilityResolverSubject.to_s, outcome: false)
          ]
          subject.outcome.must_equal false
        end
      end
    end

  end
end