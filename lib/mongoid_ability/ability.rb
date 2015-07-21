require 'cancancan'

module MongoidAbility
  class Ability
    include CanCan::Ability

    attr_reader :owner

    def initialize owner
      @owner = owner

      can do |action, subject_type, subject, options|
        _can(action, subject_type, subject, options)
        
        # if defined? Rails
        #   ::Rails.cache.fetch( [ cache_key ] + cache_keys(action, subject_type, subject, options) ) do
        #     _can(action, subject_type, subject, options)
        #   end
        # else
        #   _can(action, subject_type, subject, options)
        # end
      end
    end

    # ---------------------------------------------------------------------

    def _can action, subject_type, subject, options
      subject_class = subject_type.to_s.constantize
      outcome = nil
      options ||= {}

      subject_class.self_and_ancestors_with_default_locks.each do |cls|
        outcome = ResolveInheritedLocks.call(owner, action, cls, subject, options)
        break if outcome != nil
      end

      outcome
    end

    # ---------------------------------------------------------------------

    def cache_key
      ["ability", owner.cache_key, inherit_from_relation_cache_keys].compact.join('/')
    end

    def cache_keys action, subject_type, subject, options
      res = []
      res << action
      res << subject_type
      res << subject.cache_key unless subject.nil?
      res << options_cache_key(options)
      res.compact
    end

    def options_cache_key options={}
      Digest::SHA1.hexdigest( options.to_a.sort_by { |k,v| k.to_s }.to_s )
    end

    def inherit_from_relation_cache_keys
      return unless owner.respond_to?(owner.class.inherit_from_relation_name) && owner.inherit_from_relation != nil
      owner.inherit_from_relation.map(&:cache_key)
    end

  end
end
