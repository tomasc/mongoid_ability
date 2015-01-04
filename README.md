# Mongoid Ability

[![Build Status](https://travis-ci.org/tomasc/mongoid_ability.svg)](https://travis-ci.org/tomasc/mongoid_ability) [![Gem Version](https://badge.fury.io/rb/mongoid_ability.svg)](http://badge.fury.io/rb/mongoid_ability) [![Coverage Status](https://img.shields.io/coveralls/tomasc/mongoid_ability.svg)](https://coveralls.io/r/tomasc/mongoid_ability)

Custom `Ability` class that allows [CanCanCan](https://github.com/CanCanCommunity/cancancan) authorization library store permissions in [MongoDB](http://www.mongodb.org) via the [Mongoid](https://github.com/mongoid/mongoid) gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_ability'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install mongoid_ability
```

## Setup

The permissions are defined by a `Lock` that applies to a `Subject` and defines access for its owner – `User` and/or its `Role`.

### Lock

A `Lock` class can be any class that include `MongoidAbility::Lock`. There should be only one such class in an application.

```ruby
class MyLock
    include Mongoid::Document
    include MongoidAbility::Lock

    embedded_in :owner, polymorphic: true
end
```

This class defines a permission itself using the following fields:

`:subject_type, type: String`  
`:subject_id, type: Moped::BSON::ObjectId`  
`:action, type: Symbol, default: :read`  
`:outcome, type: Boolean, default: false`  

These fields define what subject (respectively subject type, when referring to a class) the lock applies to, which action it is defined for (for example `:read`), and whether the outcome is positive or negative.

For more specific behavior, it is possible to override the `#calculated_outcome` method (should, for example, the permission depend on some additional factors).

```ruby
def calculated_outcome
    # custom behaviour
    # returns true/false
end
```

If you wish to check the state of a lock directly, please use the convenience methods `#open?` and `#closed?`. These take into account the `#calculated_outcome`. Using the `:outcome` field directly is discouraged.

The lock class can be further subclassed in order to customise its behavior, for example per action.

### Subject

All subjects (classes which permissions you want to control) will include the `MongoidAbility::Subject` module.

Each action and its default outcome, needs to be defined using the `.default_lock` macro.

```ruby
class MySubject
    include Mongoid::Document
    include MongoidAbility::Subject

    default_lock :read, true
    default_lock :update, false
end
```

The subject classes can be subclassed. Subclasses inherit the default locks (unless they override them), the resulting outcome being correctly calculated bottom-up the superclass chain. 

The subject also acquires a convenience `Mongoid::Criteria` named `.accessible_by`. This criteria can be used to query for subject based on the user's ability:

```ruby
ability = MongoidAbility::Ability.new(current_user)
MySubject.accessible_by(ability, :read)
```

### Owner

This gem supports two levels of ownership of a lock: a `User` and its many `Role`s. The locks can be either embedded (via `.embeds_many`) or associated (via `.has_many`). Make sure to include the `as: :owner` option.

```ruby
class MyUser
    include Mongoid::Document
    include MongoidAbility::Owner

    embeds_many :locks, class_name: 'MyLock', as: :owner
    has_and_belongs_to_many :roles, class_name: 'MyRole'

    # override if your relation is named differently
    def self.roles_relation_name
        :roles
    end
end
```

```ruby
class MyRole
    include Mongoid::Document
    include MongoidAbility::Owner

    embeds_many :locks, class_name: 'MyLock', as: :owner
    has_and_belongs_to_many :users, class_name: 'MyUser'
end
```

Both users and roles can be further subclassed.

The owner also gains the `#can?` and `#cannot?` methods, that are delegate to the user's ability. It is then easy to perform permission checks per user:

```ruby
current_user.can?(:read, resource)
other_user.can?(:read, resource)
```

### CanCanCan

The default `:current_ability` defined by [CanCanCan](https://github.com/CanCanCommunity/cancancan) will be automatically overriden by the `Ability` class provided by this gem.

## Usage

1. Setup subject classes and their default locks.
2. Define permissions using lock objects embedded (or associated to) either in user or role.
3. Use standard [CanCanCan](https://github.com/CanCanCommunity/cancancan) helpers (`authorize!`, `can?`, `cannot?`) to authorize the current user.

## How it works?

The ability class in this gem looks up and calculates the outcome in the following order:

1. User locks, defined for `:subject_id`, then `:subject_type` (then its superclasses), then defined in the subject class itself (via the `.default_lock` macro) and its superclasses.
2. Role locks have the same look up chain as the user locks. The role permissions are optimistic, meaning that in case a user has multiple roles, and the roles have locks with conflicting outcomes, the ability favors the positive one.

See the test suite for more details.

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_ability/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
