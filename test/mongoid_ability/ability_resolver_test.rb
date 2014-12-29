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
      describe 'when locks on both user and its roles' do
        before do
          user.roles = [
            role_sysop.tap { |r| r.locks = [
              TestLock.new(action: :read, outcome: true, subject_type: TestAbilityResolverSubject.to_s)
            ]}
          ]
          user.locks = [
            TestLock.new(action: :read, outcome: false, subject_type: TestAbilityResolverSubject.to_s)
          ]
        end
        it 'prefers users locks' do
          subject.outcome.must_equal false
        end
      end
      describe 'when locks on roles and on class' do
        before do
          user.roles = [
            role_sysop.tap { |r| r.locks = [
              TestLock.new(action: :read, outcome: false, subject_type: TestAbilityResolverSubject.to_s)
            ]}
          ]
        end
        it 'prefers role locks' do
          subject.outcome.must_equal false
        end
      end
    end

    # ---------------------------------------------------------------------

    describe '#user_outcome' do
      describe 'no locks' do
        it 'returns nil if no locks for subject_type and action exists' do
          subject.user_outcome.must_be_nil
        end
      end

      describe 'id locks' do
        it 'returns outcome' do
          user.locks = [
            TestLock.new(action: :read, subject: ability_resolver_subject, outcome: true)
          ]
          subject_with_id.user_outcome.must_equal true
        end

        it 'prefers negative outcome' do
          user.locks = [
            TestLock.new(action: :read, subject: ability_resolver_subject, outcome: true),
            TestLock.new(action: :read, subject: ability_resolver_subject, outcome: false)
          ]
          subject_with_id.user_outcome.must_equal false
        end
      end

      describe 'class locks' do
        it 'returns outcome' do
          user.locks = [
            TestLock.new(action: :read, subject_type: TestAbilityResolverSubject.to_s, outcome: true)
          ]
          subject.user_outcome.must_equal true
        end

        it 'prefers negative outcome' do
          user.locks = [
            TestLock.new(action: :read, subject_type: TestAbilityResolverSubject.to_s, outcome: true),
            TestLock.new(action: :read, subject_type: TestAbilityResolverSubject.to_s, outcome: false)
          ]
          subject.user_outcome.must_equal false
        end
      end
    end

    # ---------------------------------------------------------------------

    describe '#roles_outcome' do
      describe 'no locks' do
        it 'returns nil if no locks for subject_type exist in any of user roles' do
          subject.roles_outcome.must_be_nil
        end
      end

      describe 'id locks' do
        it 'returns outcome' do
          user.roles = [
            role_sysop.tap{ |r| r.locks = [
              TestLock.new(subject: ability_resolver_subject, action: :read, outcome: true)
            ]},
            role_editor
          ]
          subject_with_id.roles_outcome.must_equal true
        end

        it 'prefers negative outcome across one role' do
          user.roles = [
            role_sysop.tap{ |r| r.locks = [
              TestLock.new(subject: ability_resolver_subject, action: :read, outcome: true),
              TestLock.new(subject: ability_resolver_subject, action: :read, outcome: false)
            ]},
            role_editor
          ]
          subject_with_id.roles_outcome.must_equal false
        end

        it 'prefers positive outcome across multiple roles' do
          user.roles = [
            role_sysop.tap{ |r| r.locks = [
              TestLock.new(subject: ability_resolver_subject, action: :read, outcome: true)
            ]},
            role_editor.tap{ |r| r.locks = [
              TestLock.new(subject: ability_resolver_subject, action: :read, outcome: false)
            ]}
          ]
          subject_with_id.roles_outcome.must_equal true
        end
      end

      describe 'class locks' do
        it 'returns outcome' do
          user.roles = [
            role_sysop.tap{ |r| r.locks = [
              TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: true)
            ]},
            role_editor
          ]
          subject.roles_outcome.must_equal true
        end

        it 'prefers negative outcome across one role' do
          user.roles = [
            role_sysop.tap{ |r| r.locks = [
              TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: true),
              TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: false)
            ]},
            role_editor
          ]
          subject.roles_outcome.must_equal false
        end

        it 'prefers positive outcome across multiple roles' do
          user.roles = [
            role_sysop.tap{ |r| r.locks = [
              TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: true)
            ]},
            role_editor.tap{ |r| r.locks = [
              TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: false)
            ]}
          ]

          subject.roles_outcome.must_equal true
        end
      end
    end

    # ---------------------------------------------------------------------
    
    describe '#class_outcome' do
      it 'returns outcome' do
        subject.class_outcome.must_equal true
      end

      it 'prefers negative outcome across same class' do
        TestAbilityResolverSubject.stub(:default_locks, [
          TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: false),
          TestLock.new(subject_type: TestAbilityResolverSubject.to_s, action: :read, outcome: true)
        ]) do
          subject.class_outcome.must_equal false
        end
      end
    end

  end
end