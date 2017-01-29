require "mongoid_ability/version"

require "mongoid_ability/ability"

require "mongoid_ability/lock"
require "mongoid_ability/owner"
require "mongoid_ability/subject"

require "mongoid_ability/resolver"
require "mongoid_ability/resolve_locks"
require "mongoid_ability/resolve_default_locks"
require "mongoid_ability/resolve_inherited_locks"
require "mongoid_ability/resolve_owner_locks"

require "mongoid_ability/values_for_accessible_query"
require "mongoid_ability/accessible_query_builder"

# ---------------------------------------------------------------------

if defined?(Rails)
  class ActionController::Base
    def current_ability
      @current_ability ||= MongoidAbility::Ability.new(current_user)
    end
  end
end
