require 'test_helper'

module MongoidAbility
  describe '.accessible_by' do

    # let(:role_1) { MyRole.new }
    # let(:role_2) { MyRole.new }
    # let(:owner) { MyOwner.new(my_roles: [ role_1, role_2 ]) }
    # let(:ability) { Ability.new(owner) }
    #
    # before do
    #   MySubject.default_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: true) ]
    #   MySubject1.default_locks = []
    #
    #   @my_subject = MySubject.create!
    #   @my_subject_1 = MySubject1.create!
    # end
    #
    # # =====================================================================
    #
    # describe 'default locks' do
    #   describe 'when open' do
    #     it 'returns everything' do
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject_1
    #     end
    #   end
    #
    #   describe 'when closed' do
    #     before do
    #       MySubject.default_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       MySubject1.default_locks = []
    #     end
    #
    #     it 'returns nothing' do
    #       MySubject.accessible_by(ability, :read).to_a.wont_include @my_subject
    #       MySubject.accessible_by(ability, :read).to_a.wont_include @my_subject_1
    #     end
    #   end
    # end
    #
    # # ---------------------------------------------------------------------
    #
    # describe 'subject_type lock' do
    #   describe 'on roles' do
    #     it 'overrides default lock' do
    #       role_1.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_be :empty?
    #     end
    #
    #     it 'takes the most permissive of roles' do
    #       role_1.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       role_2.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: true) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject_1
    #     end
    #   end
    #
    #   describe 'on user' do
    #     it 'overrides default lock' do
    #       owner.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_be :empty?
    #     end
    #
    #     it 'overrides role locks' do
    #       role_1.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       owner.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: true) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject_1
    #     end
    #   end
    # end
    #
    # # ---------------------------------------------------------------------
    #
    # describe 'subject_id lock' do
    #   describe 'on roles' do
    #     it 'overrides default lock' do
    #       role_1.my_locks = [ MyLock.new(subject: @my_subject, action: :read, outcome: false) ]
    #       MySubject1.accessible_by(ability, :read).to_a.wont_include @my_subject
    #     end
    #
    #     it 'overrides default negative lock' do
    #       MySubject.default_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       role_1.my_locks = [ MyLock.new(subject: @my_subject, action: :read, outcome: true) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject
    #     end
    #
    #     it 'overrides subject_type lock' do
    #       role_1.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       role_2.my_locks = [ MyLock.new(subject: @my_subject, action: :read, outcome: true) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject
    #     end
    #
    #     it 'takes the most permissive of roles' do
    #       role_1.my_locks = [ MyLock.new(subject: @my_subject, action: :read, outcome: true) ]
    #       role_2.my_locks = [ MyLock.new(subject: @my_subject, action: :read, outcome: false) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject
    #     end
    #
    #     describe 'for subclasses' do
    #       it 'overrides default negative lock' do
    #         MySubject.default_locks = [ MyLock.new(subject_type: MySubject1, action: :read, outcome: false) ]
    #         role_1.my_locks = [ MyLock.new(subject: @my_subject_1, action: :read, outcome: true) ]
    #         MySubject.accessible_by(ability, :read).to_a.wont_include @my_subject
    #         MySubject.accessible_by(ability, :read).to_a.must_include @my_subject_1
    #       end
    #     end
    #   end
    #
    #   describe 'on user' do
    #     it 'overrides default lock' do
    #       owner.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_be :empty?
    #     end
    #
    #     it 'overrides subject_type lock' do
    #       owner.my_locks = [
    #         MyLock.new(subject_type: MySubject, action: :read, outcome: false),
    #         MyLock.new(subject_type: MySubject1, action: :read, outcome: true)
    #       ]
    #       MySubject.accessible_by(ability, :read).to_a.wont_include @my_subject
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject_1
    #     end
    #
    #     it 'overrides role locks' do
    #       role_1.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: false) ]
    #       owner.my_locks = [ MyLock.new(subject_type: MySubject, action: :read, outcome: true) ]
    #       MySubject.accessible_by(ability, :read).to_a.must_include @my_subject
    #     end
    #   end
    # end

  end
end
