require 'test_helper'

module MongoidAbility
  describe Subject do

    def subject_type_lock subject_cls, outcome
      TestLock.new(subject_type: subject_cls.to_s, action: :read, outcome: outcome)
    end

    def subject_lock subject, outcome
      TestLock.new(subject: subject, action: :read, outcome: outcome)
    end

    # ---------------------------------------------------------------------

    subject { SubjectTest.new }

    let(:subject_single_test) { SubjectSingleTest.create! }

    let(:subject_test_1) { SubjectTestOne.create! }
    let(:subject_test_2) { SubjectTestTwo.create! }

    let(:role_1) { TestRole.new }
    let(:role_2) { TestRole.new }

    let(:user) { TestUser.new(roles: [role_1, role_2]) }
    let(:ability) { Ability.new(user) }

    # =====================================================================

    describe 'class methods' do
      it 'has .default_locks' do
        subject.class.must_respond_to :default_locks
        subject.class.default_locks.must_be_kind_of Array
      end

      it 'has .default_lock' do
        subject.class.must_respond_to :default_lock
      end

      describe '.default_lock' do
        it 'sets up new Lock' do
          lock = subject.class.default_locks.first
          subject.class.default_locks.length.must_equal 1
          lock.subject_type.must_equal subject.class.model_name
          lock.subject_id.must_be_nil
          lock.action.must_equal :read
        end
      end

      # =====================================================================

      describe '.ancestors_with_default_locks' do
        it 'lists ancestors with default locks' do
          subject_test_1.class.ancestors_with_default_locks.must_equal [subject.class]
        end
      end

      describe '.self_and_ancestors_with_default_locks' do
        it 'lists self and ancestors with default locks' do
          subject_test_1.class.self_and_ancestors_with_default_locks.must_equal [subject_test_1.class, subject.class]
        end
      end

      # =====================================================================

      describe '.accessible_by' do
        before do
          subject_test_1
          subject_test_2
          subject_single_test
        end

        it 'returns Mongoid::Criteria' do
          subject.class.accessible_by(ability).must_be_kind_of Mongoid::Criteria
        end

        # ---------------------------------------------------------------------

        describe 'default locks' do
          it 'returns everything when open' do
            subject.class.stub(:default_locks, [ subject_type_lock(subject.class, true) ]) do
              subject.class.accessible_by(ability).must_include subject_test_1
              subject.class.accessible_by(ability).must_include subject_test_2
            end
          end

          describe 'single class' do
            it 'returns everything when open' do
              subject_single_test.class.stub(:default_locks, [ subject_type_lock(subject_single_test.class, true) ]) do
                subject_single_test.class.accessible_by(ability).must_include subject_single_test
              end
            end
          end

          it 'returns nothing when closed' do
            subject.class.stub(:default_locks, [ subject_type_lock(subject.class, false) ]) do
              subject.class.accessible_by(ability).must_be :empty?
            end
          end

          describe 'single class' do
            it 'returns nothing when closed' do
              subject_single_test.class.stub(:default_locks, [ subject_type_lock(subject_single_test.class, false) ]) do
                subject_single_test.class.accessible_by(ability).wont_include subject_single_test
              end
            end
          end
        end

        # ---------------------------------------------------------------------

        describe 'subject_type lock' do
          describe 'on roles' do
            it 'overrides default lock' do
              role_1.test_locks = [ subject_type_lock(subject.class, false) ]
              subject.class.accessible_by(ability).must_be :empty?
            end
            it 'takes the most permissive of roles' do
              role_1.test_locks = [ subject_type_lock(subject.class, false) ]
              role_2.test_locks = [ subject_type_lock(subject.class, true) ]
              subject.class.accessible_by(ability).must_include subject_test_1
              subject.class.accessible_by(ability).must_include subject_test_2
            end
          end

          describe 'on user' do
            it 'overrides default lock' do
              user.test_locks = [ subject_type_lock(subject.class, false) ]
              subject.class.accessible_by(ability).must_be :empty?
            end
            it 'overrides role locks' do
              role_1.test_locks = [ subject_type_lock(subject.class, false) ]
              user.test_locks = [ subject_type_lock(subject.class, true) ]
              subject.class.accessible_by(ability).must_include subject_test_1
              subject.class.accessible_by(ability).must_include subject_test_2
            end
          end
        end

        # ---------------------------------------------------------------------

        describe 'subject_id lock' do
          describe 'on roles' do
            it 'overrides default lock' do
              role_1.test_locks = [ subject_lock(subject_test_1, false) ]
              subject.class.accessible_by(ability).wont_include subject_test_1
            end

            it 'overrides default negative lock' do
              subject.class.stub(:default_locks, [ subject_type_lock(subject_test_1.class, false) ]) do
                role_1.test_locks = [ subject_lock(subject_test_1, true) ]
                subject.class.accessible_by(ability).must_include subject_test_1
              end
            end

            it 'overrides subject_type lock' do
              role_1.test_locks = [ subject_type_lock(subject_test_2.class, false) ]
              role_2.test_locks = [ subject_lock(subject_test_2, true) ]
              subject.class.accessible_by(ability).must_include subject_test_2
            end

            it 'overrides default negative lock' do
              subject.class.stub(:default_locks, [ subject_type_lock(subject_test_2.class, false) ]) do
                role_2.test_locks = [ subject_lock(subject_test_2, true) ]
                subject.class.accessible_by(ability).wont_include subject_test_1
                subject.class.accessible_by(ability).must_include subject_test_2
              end
            end

            it 'takes the most permissive of roles' do
              role_1.test_locks = [ subject_lock(subject_test_2, false) ]
              role_2.test_locks = [ subject_lock(subject_test_2, true) ]
              subject.class.accessible_by(ability).must_include subject_test_2
            end
          end

          describe 'on user' do
            it 'overrides default lock' do
              user.test_locks = [ subject_lock(subject_test_1, false) ]
              subject.class.accessible_by(ability).wont_include subject_test_1
              subject.class.accessible_by(ability).must_include subject_test_2
            end

            it 'overrides subject_type lock' do
              user.test_locks = [ subject_type_lock(subject_test_1.class, true), subject_lock(subject_test_1, false) ]
              subject.class.accessible_by(ability).wont_include subject_test_1
            end

            it 'overrides role locks' do
              role_1.test_locks = [ subject_lock(subject_test_2, false) ]
              user.test_locks = [ subject_lock(subject_test_2, true) ]
              subject.class.accessible_by(ability).must_include subject_test_2
            end

            it 'overrides default negative lock' do
              subject.class.stub(:default_locks, [ subject_type_lock(subject_test_2.class, false) ]) do
                user.test_locks = [ subject_lock(subject_test_2, true) ]
                subject.class.accessible_by(ability).must_include subject_test_2
              end
            end
          end
        end

      end
    end
  end

end
