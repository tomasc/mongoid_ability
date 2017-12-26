module CanCan
  module ModelAdapters
    class MongoidAdapter < AbstractAdapter
      def self.for_class?(model_class)
        model_class <= Mongoid::Document
      end

      # Used to determine if this model adapter will override the matching behavior for a hash of conditions.
      # If this returns true then matches_conditions_hash? will be called. See Rule#matches_conditions_hash
      def self.override_conditions_hash_matching?(_subject, _conditions)
        false
      end

      # Override if override_conditions_hash_matching? returns true
      def self.matches_conditions_hash?(_subject, _conditions)
        raise NotImplemented, 'This model adapter does not support matching on a conditions hash.'
      end

      # Used to determine if this model adapter will override the matching behavior for a specific condition.
      # If this returns true then matches_condition? will be called. See Rule#matches_conditions_hash
      def self.override_condition_matching?(_subject, _name, _value)
        false
      end

      # Override if override_condition_matching? returns true
      def self.matches_condition?(_subject, _name, _value)
        raise NotImplemented, 'This model adapter does not support matching on a specific condition.'
      end

      def initialize(model_class, rules, options = {})
        @model_class = model_class
        @rules = rules
        @options = options
      end

      def subject_types
        @subject_types ||= begin
          root_cls = @model_class.root_class

          (Array(root_cls) + root_cls.descendants).inject([]) do |res, cls|
            subject_type_rules_for(cls).each do |rule|
              if rule.base_behavior
                # if closed rule exists, remove cls & descendants from result
                res += (Array(cls) + cls.descendants)
              else
                # if open rules exists, add cls & descendants from resul
                res -= (Array(cls) + cls.descendants)
              end
            end

            res
          end
        end
      end

      def open_conditions
        @open_conditions ||= begin
          condition_rules.select(&:base_behavior).each_with_object([]) do |rule, res|
            res << apply_prefix_to_conditions(rule.conditions)
          end
        end
      end

      def closed_conditions
        @closed_conditions ||= begin
          condition_rules.reject(&:base_behavior).each_with_object([]) do |rule, res|
            res << @model_class.criteria.excludes(apply_prefix_to_conditions(rule.conditions)).selector
          end
        end
      end

      def subject_type_conditions
        return unless subject_types.present?
        { :"#{type_key}".in => subject_types }
      end

      def has_any_conditions?
        subject_type_conditions.present? ||
          open_conditions.present? ||
          closed_conditions.present?
      end

      def database_records
        return @model_class.none unless has_any_conditions?

        @model_class.where(
          '$and' => [
            { '$or' => ([subject_type_conditions] + open_conditions).compact }
          ] + closed_conditions
        )
      end

      private

      def subject_type_rules_for(subject_type)
        subject_type_rules.select do |rule|
          rule.subjects.include?(subject_type)
        end
      end

      def subject_type_rules
        @subject_type_rules ||= begin
          @rules.reject { |rule| rule.conditions.present? }
        end
      end

      def condition_rules
        @condition_rules ||= begin
          @rules.select { |rule| rule.conditions.present? }
        end
      end

      def prefix
        @options.fetch(:prefix, nil)
      end

      def apply_prefix_to_conditions(conditions = {})
        return conditions unless prefix.present?
        conditions.inject({}) do |h, (k, v)|
          if %i(id _id).include?(k.to_sym)
            h.merge(id_key => v)
          else
            h.merge(k => v)
          end
        end
      end

      def id_key
        @id_key ||= [prefix, '_id'].reject(&:blank?).join.to_sym
      end

      def type_key
        @type_key ||= [prefix, '_type'].reject(&:blank?).join.to_sym
      end
    end
  end
end

# simplest way to add `accessible_by` to all Mongoid Documents
module Mongoid::Document::ClassMethods
  include CanCan::ModelAdditions::ClassMethods
end