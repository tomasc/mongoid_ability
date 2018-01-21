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
        true
      end

      # Override if override_condition_matching? returns true
      def self.matches_condition?(subject, name, value)
        attribute = subject.send(name)

        case value
        when Hash then hash_condition_match?(attribute, value)
        when Range then value.cover?(attribute)
        when Regexp then value.match(attribute)
        when Array then value.include?(attribute)
        when Enumerable then value.include?(attribute)
        else attribute == value
        end
      end

      def initialize(model_class, rules, options = {})
        @model_class = model_class
        @rules = rules
        @options = options
      end

      def subject_types
        @subject_types ||= begin
          root_cls = @model_class.root_class
          [root_cls, *root_cls.descendants].compact
        end
      end

      def open_subject_types
        @open_subject_types ||= begin
          subject_types.inject([]) do |res, cls|
            subject_type_rules_for(cls).each do |rule|
              cls_list = [cls, *cls.descendants].compact
              rule.base_behavior ? res += cls_list : res -= cls_list
            end
            res.uniq
          end
        end
      end

      def closed_subject_types
        @closed_subject_types ||= begin
          subject_types - open_subject_types
        end
      end

      def open_conditions
        @open_conditions ||= begin
          condition_rules.select(&:base_behavior).each_with_object([]) do |rule, res|
            rule.conditions.each do |key, value|
              key = id_key if %i[id _id].include?(key.to_sym)
              res <<  case value
                      when Array then { key => { '$in' => value } }
                      else { key => value }
                      end
            end
          end
        end
      end

      def closed_conditions
        @closed_conditions ||= begin
          condition_rules.reject(&:base_behavior).each_with_object([]) do |rule, res|
            rule.conditions.each do |key, value|
              key = id_key if %i[id _id].include?(key.to_sym)
              res <<  case value
                      when Regexp then { key => { '$not' => value } }
                      when Array then { key => { '$nin' => value } }
                      else { key => { '$ne' => value } }
                      end
            end
          end
        end
      end

      def subject_type_conditions
        return unless open_subject_types.present?
        { :"#{type_key}".nin => closed_subject_types.map(&:to_s) }
      end

      def has_any_conditions?
        subject_type_conditions.present? ||
          open_conditions.present? ||
          closed_conditions.present?
      end

      def database_records
        return @model_class.none unless has_any_conditions?

        or_conditions = { '$or' => ([subject_type_conditions, *open_conditions]).compact }
        or_conditions = nil if or_conditions['$or'].empty?

        and_conditions = { '$and' => [or_conditions, *closed_conditions].compact }
        and_conditions = nil if and_conditions['$and'].empty?

        @model_class.where(and_conditions)
      end

      private

      def subject_type_rules_for(subject_type)
        subject_type_rules.select do |rule|
          rule.subjects.include?(subject_type)
        end
      end

      def subject_type_rules
        @rules.reject { |rule| rule.conditions.present? }
      end

      def condition_rules
        @rules.select { |rule| rule.conditions.present? }
      end

      def prefix
        @options.fetch(:prefix, nil)
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
