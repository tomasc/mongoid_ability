require 'test_helper'

module MongoidAbility
  describe Subject do

    def default_lock subject_cls, outcome
      TestLock.new(subject_type: subject_cls.to_s, action: :read, outcome: outcome)
    end

    def subject_lock subject, outcome
      TestLock.new(subject: subject, action: :read, outcome: outcome)
    end

    # ---------------------------------------------------------------------

    subject { TestSubject.new }

    let(:subject_test_1) { TestSubject.create! }
    let(:subject_test_2) { TestSubject.create! }

    let(:subject_super) { TestSubjectSuper.new }

    let(:embedded_test_subject_1) { EmbeddedTestSubject.new }
    let(:embedded_test_subject_2) { EmbeddedTestSubject.new }
    let(:embedded_test_subject_owner) { EmbeddedTestSubjectOwner.new(embedded_test_subjects: [ embedded_test_subject_1, embedded_test_subject_2 ]) }

    let(:user) { TestUser.new }
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
          subject.class.ancestors_with_default_locks.must_equal [TestSubjectSuper]
        end
      end

      describe '.self_and_ancestors_with_default_locks' do
        it 'lists self and ancestors with default locks' do
          subject.class.self_and_ancestors_with_default_locks.must_equal [TestSubject, TestSubjectSuper]
        end
      end

      # =====================================================================

      describe '.accessible_by' do

        it 'returns Mongoid::Criteria' do
          subject.class.accessible_by(ability).must_be_kind_of Mongoid::Criteria
          embedded_test_subject_1.class.accessible_by(ability).must_be_kind_of Mongoid::Criteria
        end

        describe 'embedded relations' do
          it 'returns correct criteria type' do
            embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).embedded?.must_equal true
          end
        end

        # ---------------------------------------------------------------------

        describe 'default locks' do
          describe 'referenced relations' do
            it 'returns everything when open' do
              subject_test_1
              subject_test_2

              subject.class.stub(:default_locks, [ default_lock(subject_test_1.class, true) ]) do
                subject.class.accessible_by(ability).must_include subject_test_1
                subject.class.accessible_by(ability).must_include subject_test_2
              end
            end

            it 'returns nothing when closed' do
              subject.class.stub(:default_locks, [ default_lock(subject_test_1.class, false) ]) do
                subject.class.accessible_by(ability).must_be :empty?
              end
            end
          end

          describe 'embedded relations' do
            it 'returns everything when open' do
              subject.class.stub(:default_locks, [ default_lock(embedded_test_subject_1.class, true) ]) do
                embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).must_include embedded_test_subject_1
                embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).must_include embedded_test_subject_2
              end
            end

            it 'returns nothing when closed' do
              subject.class.stub(:default_locks, [ default_lock(embedded_test_subject_1.class, false) ]) do
                embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).must_be :empty?
              end
            end
          end
        end

        # ---------------------------------------------------------------------

        describe 'id locks' do
          describe 'referenced relations' do
            it 'excludes subject when closed' do
              user.test_locks = [ subject_lock(subject_test_1, true), subject_lock(subject_test_2, false) ]
              subject.class.accessible_by(ability).must_include subject_test_1
              subject.class.accessible_by(ability).wont_include subject_test_2
            end
          end

          describe 'embedded relations' do
            it 'excludes subject when closed' do
              user.test_locks = [ subject_lock(embedded_test_subject_1, true), subject_lock(embedded_test_subject_2, false) ]
              embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).must_include embedded_test_subject_1
              embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).wont_include embedded_test_subject_2
            end
          end
        end

        # ---------------------------------------------------------------------

        describe 'default locks & id locks' do
          describe 'referenced relations' do
            describe 'default open' do
              it 'excludes subject when id lock closed' do
                subject.class.stub(:default_locks, [ default_lock(subject_test_1.class, true) ]) do
                  user.test_locks = [ subject_lock(subject_test_2, false) ]
                  subject.class.accessible_by(ability).must_include subject_test_1
                  subject.class.accessible_by(ability).wont_include subject_test_2
                end
              end
            end

            describe 'default closed' do
              it 'includes subject when id lock open' do
                subject.class.stub(:default_locks, [ default_lock(subject_test_1.class, false) ]) do
                  user.test_locks = [ subject_lock(subject_test_2, true) ]
                  subject.class.accessible_by(ability).wont_include subject_test_1
                  subject.class.accessible_by(ability).must_include subject_test_2
                end
              end
            end
          end

          describe 'embedded relations' do
            describe 'default open' do
              it 'excludes subject when id lock closed' do
                subject.class.stub(:default_locks, [ default_lock(embedded_test_subject_1.class, true) ]) do
                  user.test_locks = [ subject_lock(embedded_test_subject_2, false) ]
                  embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).must_include embedded_test_subject_1
                  embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).wont_include embedded_test_subject_2
                end
              end
            end

            describe 'default closed' do
              it 'includes subject when id lock open' do
                subject.class.stub(:default_locks, [ default_lock(embedded_test_subject_1.class, false) ]) do
                  user.test_locks = [ subject_lock(embedded_test_subject_2, true) ]
                  embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).wont_include embedded_test_subject_1
                  embedded_test_subject_owner.embedded_test_subjects.accessible_by(ability).must_include embedded_test_subject_2
                end
              end
            end
          end
        end

      end
    end
  end

end