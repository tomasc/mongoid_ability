# CHANGELOG

## 2.0.1

* make sure all `subject_id` values are converted to BSON

## 2.0.0

* Full rewrite, which more closely follows the `CanCanCan` conventions: instead of custom algorithm for resolving permissions, the `Lock` documents are now converted to standard `CanCanCan` rules. Similarly the `.acessible_by` criteria are now handled by standard model adapter (`MongoidAdapter`), to be extracted to separate gem. Therefore this gem can benefit for potential future performance improvements of `CanCanCan`. Lastly, the `ability` objects are now cacheable, therefore the conversion of `Lock` documents to `CanCanCan` rule objects does not need to be performed on every request.

## 1.0.0

* conforms to '[MONGOID-4418](https://jira.mongodb.org/browse/MONGOID-4418) Don't allow PersistenceContext method as field names' by renaming the `Lock` field `:options` to `:opts` (but aliasing it `as: :options`). As a result the `Mongoid::Ability` API stays unchanged, however in some cases it might be necessary to migrate the values from the `:options` fields to the new `:opts`.

## 0.4.3

* stub `default_locks` in tests to avoid brittle tests
* fix the ability syntactic sugar to support both proc & direct call

## 0.4.2

* **yanked**
* improved clarity in class naming

## 0.4.1

* **yanked**
* `Resolver` classes now accept `subject_id` (instead of `subject`) for greater flexibility

## 0.4.0

* **yanked**
* the `Resolver` classes refactored to return locks (instead of just an outcome)
