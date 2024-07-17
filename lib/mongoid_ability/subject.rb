# frozen_string_literal: true

# TODO: rewrite as concern, use proc for the _type or consider either using
# discriminator_key or maybe even better add our own configurable discriminator
# key (.ability_subject_discriminator_key), to not rely on mongoid internals?
#
# https://github.com/mongodb/mongoid/blob/01ee33970c5e9cefe436528c56c32e843f474e9b/lib/mongoid/traversable.rb

module MongoidAbility
  module Subject
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        include Mongoid::Touchable::InstanceMethods

        field :_type, type: String, default: -> { model_name }
      end
    end

    module ClassMethods
      def default_locks
        @default_locks ||= LocksDecorator.new([])
      end

      def reset_default_locks!
        @default_locks = LocksDecorator.new([])
      end

      def default_locks=(locks)
        @default_locks = locks
      end

      def default_lock(lock_cls, action, outcome, options = {})
        lock = lock_cls.new(subject_type: to_s, action: action, outcome: outcome, options: options)

        # remove any existing locks
        if existing_lock = default_locks.detect { |l| l.action == lock.action && l.options == lock.options }
          default_locks.delete(existing_lock)
        end

        # add new lock
        default_locks.push(lock)
      end

      def self_and_ancestors_with_default_locks
        ancestors.select { |a| a.is_a?(Class) && a.respond_to?(:default_locks) }
      end

      def ancestors_with_default_locks
        self_and_ancestors_with_default_locks - [self]
      end

      def is_root_class?
        root_class == self
      end

      def root_class
        self_and_ancestors_with_default_locks.last
      end

      def has_default_lock_for_action?(action)
        default_locks.for_action(action).present?
      end
    end
  end
end
