require "mongoid_ability/version"

require "mongoid_ability/ability"
require "mongoid_ability/ability_resolver"
require "mongoid_ability/lock"
require "mongoid_ability/owner"
require "mongoid_ability/subject"

# ---------------------------------------------------------------------

# class ActionController::Base
#   def current_ability
#     @current_ability ||= MongoidAbility::Ability.new(current_user)
#   end
# end