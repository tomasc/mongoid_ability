require "test_helper"

module CanCan
  module ModelAdapters
    describe MongoidAdapter do
      describe ".accessible_by" do
        describe "Boolean" do
          it "returns correct records when using positive locks" do
            MySubject.default_lock MyLock, :read, true, override: true
            unaccessible = MySubject.create!
            accessible = MySubject.create!(override: true)

            _(MySubject.accessible_by(ability)).wont_include unaccessible
            _(MySubject.accessible_by(ability)).must_include accessible
          end

          it "returns the correct records when using negative locks" do
            MySubject.default_lock MyLock, :read, true
            MySubject.default_lock MyLock, :read, false, override: true
            accessible = MySubject.create!
            unaccessible = MySubject.create!(override: true)

            _(MySubject.accessible_by(ability)).must_include accessible
            _(MySubject.accessible_by(ability)).wont_include unaccessible
          end
        end

        describe "String" do
          it "returns correct records when using positive locks" do
            MySubject.default_lock MyLock, :read, true, str_val: "Jan Tschichold"
            unaccessible = MySubject.create!
            accessible = MySubject.create!(str_val: "Jan Tschichold")

            _(MySubject.accessible_by(ability)).wont_include unaccessible
            _(MySubject.accessible_by(ability)).must_include accessible
          end

          it "returns the correct records when using negative locks" do
            MySubject.default_lock MyLock, :read, true
            MySubject.default_lock MyLock, :read, false, str_val: "Jan Tschichold"
            accessible = MySubject.create!
            unaccessible = MySubject.create!(str_val: "Jan Tschichold")

            _(MySubject.accessible_by(ability)).must_include accessible
            _(MySubject.accessible_by(ability)).wont_include unaccessible
          end
        end

        describe "Regexp" do
          it "returns correct records when using positive locks" do
            MySubject.default_lock MyLock, :read, true, str_val: /tschichold/i
            unaccessible = MySubject.create!
            accessible = MySubject.create!(str_val: "Jan Tschichold")

            _(MySubject.accessible_by(ability)).wont_include unaccessible
            _(MySubject.accessible_by(ability)).must_include accessible
          end

          it "returns the correct records when using negative locks" do
            MySubject.default_lock MyLock, :read, true
            MySubject.default_lock MyLock, :read, false, str_val: /tschichold/i
            accessible = MySubject.create!
            unaccessible = MySubject.create!(str_val: "Jan Tschichold")

            _(MySubject.accessible_by(ability)).must_include accessible
            _(MySubject.accessible_by(ability)).wont_include unaccessible
          end
        end

        describe "Array" do
          it "returns correct records when using positive locks" do
            MySubject.default_lock MyLock, :read, true, str_val: %w[John Paul George Ringo]
            unaccessible = MySubject.create!
            accessible = MySubject.create!(str_val: "John")

            _(MySubject.accessible_by(ability)).wont_include unaccessible
            _(MySubject.accessible_by(ability)).must_include accessible
          end

          it "returns the correct records when using negative locks" do
            MySubject.default_lock MyLock, :read, true
            MySubject.default_lock MyLock, :read, false, str_val: %w[John Paul George Ringo]
            accessible = MySubject.create!
            unaccessible = MySubject.create!(str_val: "John")

            _(MySubject.accessible_by(ability)).must_include accessible
            _(MySubject.accessible_by(ability)).wont_include unaccessible
          end
        end

        private

        def owner
          MyOwner.new
        end

        def ability
          MongoidAbility::Ability.new(owner)
        end
      end
    end
  end
end
