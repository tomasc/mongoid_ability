# Mongoid Ability

[![Build Status](https://travis-ci.org/tomasc/mongoid_ability.svg)](https://travis-ci.org/tomasc/mongoid_ability) [![Gem Version](https://badge.fury.io/rb/mongoid_ability.svg)](http://badge.fury.io/rb/mongoid_ability) [![Coverage Status](https://img.shields.io/coveralls/tomasc/mongoid_ability.svg)](https://coveralls.io/r/tomasc/mongoid_ability)

Custom `Ability` class that allows [CanCanCan](https://github.com/CanCanCommunity/cancancan) authorization library store permissions in [MongoDB](http://www.mongodb.org) via the [Mongoid](https://github.com/mongoid/mongoid) gem.

## ToDo

* Where and how to specify the lock class? The automatic detection does not take into account subclassing, for example.

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

The permissions are defined by the `Lock` that applies to a `Subject` and defines access for its owner – `User` or `Role`.

### Lock

The `Lock` class defines the permission itself:

```ruby
class MyLock
    include Mongoid::Document
    include MongoidAbility::Lock
end
```

The lock class will have the following fields:

`:subject_type, type: String`  
`:subject_id, type: Moped::BSON::ObjectId`  
`:action, type: Symbol, default: :read`  
`:outcome, type: Boolean, default: false`  

These fields define what subject (respectively subject type, when referring to a class) the lock applies to, which action it is defined for (for example `:read`), and whether the outcome is positive or negative.

The lock class can be further subclassed in order to customise its behavior, for example per action.

For more specific behavior, it is possible to override the `:calculated_outcome` method (for example when the lock outcome should depend on more factors).

```ruby
def calculated_outcome
    # custom behaviour, that always returns Boolean
end
```

### Subject

All subjects have to include the `Subject` module, and the run the `has_locks` macro defining the association name and name of the lock class.

Each action and its default outcome (to be used for this subject), needs to be defined using the `default_lock` macro.

```ruby
class MySubject
    include Mongoid::Document
    include MongoidAbility::Subject

    default_lock :read, true
    default_lock :update, false
end
```

The subject class can be subclassed. Subclasses inherit the default locks (unless overridden), the resulting outcome being correctly calculated bottom-up the superclass chain. 

The subject also acquires a convenience Mongoid::Criteria named `accessible_by` method. This criteria can be used to query for subject based on the user's ability, such as:

```ruby
ability = MongoidAbility::Ability.new(current_user)
MySubject.accessible_by(ability, :read)
```

### Owner

This gem supports two levels of ownership of a lock: a `User` and a `Role`. The locks should be embedded in one of these models (via the `embeds_many` Mongoid relation).

```ruby
class MyUser
    include Mongoid::Document
    include MongoidAbility::Owner

    has_and_belongs_to_many :roles, class_name: 'MyRole'
end
```

```ruby
class MyRole
    include Mongoid::Document
    include MongoidAbility::Owner

    has_and_belongs_to_many :users, class_name: 'MyUser'
end
```

The relations to users' roles is by default expected to be named `:roles`. You can however override it by overriding the following class method:

```ruby
def self.roles_relation_name
    :my_roles
end
```

Again, both users and roles can be subclassed, should you need to customise their behavior.

### CanCanCan

The default `:current_ability` defined by [CanCanCan](https://github.com/CanCanCommunity/cancancan) will be automatically overriden by the `Ability` class provided by this gem.

## Usage

1. Setup subject classes and their default locks.
2. Define permissions using lock objects embedded either in user or role.
3. Use standard [CanCanCan](https://github.com/CanCanCommunity/cancancan) helpers (`authorize!`, `can?`, `cannot?`) to authorize the current user.

## How it works?

The ability class in this gem looks up and calculates the outcome in the following order:

1. User locks, defined for `subject_id`, then `subject_type` (then its superclasses), then defined in the subject class itself (via the `default_lock` macro) and its superclasses.
2. Role locks have the same look up chain as the user locks. The role permissions are optimistic, meaning that in case a user has multiple roles, and the roles have locks with conflicting outcomes, the ability favors the positive one.

See the test suite for more details.

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_ability/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
