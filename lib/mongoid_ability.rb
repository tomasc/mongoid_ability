require "mongoid_ability/version"

require "mongoid_ability/ability"

require "mongoid_ability/lock"
require "mongoid_ability/owner"
require "mongoid_ability/subject"

require "mongoid_ability/locks_resolver"
require "mongoid_ability/inherited_locks_resolver"
require "mongoid_ability/owner_locks_resolver"

require "mongoid_ability/accessible_query_builder"

# ---------------------------------------------------------------------

if defined?(Rails)
  class ActionController::Base
    def current_ability
      @current_ability ||= MongoidAbility::Ability.new(current_user)
    end
  end
end
