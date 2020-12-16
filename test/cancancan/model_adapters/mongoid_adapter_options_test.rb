require 'test_helper'

module CanCan
  module ModelAdapters
    describe MongoidAdapter do
      describe '.accessible_by' do
        let(:owner) { MyOwner.new }
        let(:ability) { MongoidAbility::Ability.new(owner) }
        let(:subject1) { MySubject.new }

        before do
          subject1.save!
          subject2.save!
        end

        describe 'Boolean' do
          let(:subject2) { MySubject.new(override: true) }

          describe 'positive' do
            before(:all) { MySubject.default_lock MyLock, :read, true, override: true }

            it { _(MySubject.accessible_by(ability)).wont_include subject1 }
            it { _(MySubject.accessible_by(ability)).must_include subject2 }
          end

          describe 'negative' do
            before(:all) do
              MySubject.default_lock MyLock, :read, true
              MySubject.default_lock MyLock, :read, false, override: true
            end

            it { _(MySubject.accessible_by(ability)).must_include subject1 }
            it { _(MySubject.accessible_by(ability)).wont_include subject2 }
          end
        end

        describe 'String' do
          let(:subject2) { MySubject.new(str_val: "Jan Tschichold") }

          describe 'positive' do
            before(:all) { MySubject.default_lock MyLock, :read, true, str_val: 'Jan Tschichold' }

            it { _(MySubject.accessible_by(ability)).wont_include subject1 }
            it { _(MySubject.accessible_by(ability)).must_include subject2 }
          end

          describe 'negative' do
            before(:all) do
              MySubject.default_lock MyLock, :read, true
              MySubject.default_lock MyLock, :read, false, str_val: 'Jan Tschichold'
            end

            it { _(MySubject.accessible_by(ability)).must_include subject1 }
            it { _(MySubject.accessible_by(ability)).wont_include subject2 }
          end
        end

        describe 'Regexp' do
          let(:subject2) { MySubject.new(str_val: "Jan Tschichold") }

          describe 'positive' do
            before(:all) { MySubject.default_lock MyLock, :read, true, str_val: /tschichold/i }

            it { _(MySubject.accessible_by(ability)).wont_include subject1 }
            it { _(MySubject.accessible_by(ability)).must_include subject2 }
          end

          describe 'negative' do
            before(:all) do
              MySubject.default_lock MyLock, :read, true
              MySubject.default_lock MyLock, :read, false, str_val: /tschichold/i
            end

            it { _(MySubject.accessible_by(ability)).must_include subject1 }
            it { _(MySubject.accessible_by(ability)).wont_include subject2 }
          end
        end

        describe 'Array' do
          let(:subject2) { MySubject.new(str_val: "John") }

          describe 'positive' do
            before(:all) { MySubject.default_lock MyLock, :read, true, str_val: %w(John Paul George Ringo) }

            it { _(MySubject.accessible_by(ability)).wont_include subject1 }
            it { _(MySubject.accessible_by(ability)).must_include subject2 }
          end

          describe 'negative' do
            before(:all) do
              MySubject.default_lock MyLock, :read, true
              MySubject.default_lock MyLock, :read, false, str_val: %w(John Paul George Ringo)
            end

            it { _(MySubject.accessible_by(ability)).must_include subject1 }
            it { _(MySubject.accessible_by(ability)).wont_include subject2 }
          end
        end
      end
    end
  end
end
