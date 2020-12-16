require 'cancancan'
require 'mongoid'

require 'cancancan/model_adapters/mongoid_adapter'
require 'cancancan/model_additions'

require 'mongoid_ability/version'

require 'mongoid_ability/ability'

require 'mongoid_ability/lock'
require 'mongoid_ability/owner'
require 'mongoid_ability/subject'

require 'mongoid_ability/locks_decorator'
require 'mongoid_ability/find_lock'

if defined?(Rails)
  class ActionController::Base
    def current_ability
      @current_ability ||= MongoidAbility::Ability.new(current_user)
    end
  end
end
