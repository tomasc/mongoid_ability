require 'cancancan'

module MongoidAbility
  class Ability
    include CanCan::Ability

    attr_reader :owner

    def self.subject_classes
      Object.descendants.select { |cls| cls.included_modules.include?(MongoidAbility::Subject) }
    end

    def self.subject_root_classes
      subject_classes.reject { |cls| cls.superclass.included_modules.include?(MongoidAbility::Subject) }
    end

    def initialize(owner)
      @owner = owner
      @cached_outcomes ||= {}

      can do |action, subject_type, subject, options = {}|
        subject_id = subject ? subject.id : nil
        cache_key = cache_key_for(action, subject_type, subject_id, options)

        unless @cached_outcomes.has_key?(cache_key)
          @cached_outcomes[cache_key] = begin
            if lock = ResolveLocks.call(owner, action, subject_type, subject_id, options)
              lock.calculated_outcome(options)
            end
          end
        else
          @cached_outcomes[cache_key]
        end
      end
    end

    # lambda for easy permission checking:
    # .select(&current_ability.can_read)
    # .select(&current_ability.can_update)
    # .select(&current_ability.can_destroy)
    # etc.
    def method_missing(name, *args)
      return super unless name.to_s =~ /\A(can|cannot)_/
      return unless action = name.to_s.scan(/\A(can|cannot)_(\w+)/).flatten.last.to_sym

      if args.empty? || args.first.is_a?(Hash)
        case name
        when /can_/ then -> (doc) { can?(action, doc, *args) }
        else -> (doc) { cannot?(action, doc, *args) }
        end
      else
        case name
        when /can_/ then can?(action, *args)
        else cannot?(action, *args)
        end
      end
    end

    private

    def cache_key_for(action, subject_type, subject_id, options = {})
      res = [action.to_s]

      if subject_id.nil?
        res << subject_type
      elsif subject_ids_from_locks.include?(subject_id)
        res << subject_id.to_s
      else
        res << subject_type
      end

      unless options.empty?
        res << Array(flatten_nested_hash.call(options)).flatten.compact.map(&:to_s)
      end

      res.join('/')
    end

    def subject_ids_from_locks
      @owner_locks ||= begin
        from_owner = owner.locks_relation.id_locks.pluck(:subject_id)
        from_rel = []

        if owner.respond_to?(owner.class.inherit_from_relation_name) && !owner.inherit_from_relation.nil?
          from_rel = owner.inherit_from_relation.flat_map do |rel|
            rel.locks_relation.id_locks.pluck(:subject_id)
          end.compact
        end

        from_owner + from_rel
      end
    end

    def flatten_nested_hash
      -> (h) { h.is_a?(Hash) ? h.flat_map { |k, v| [k, *flatten_nested_hash.call(v)] } : h }
    end
  end
end
