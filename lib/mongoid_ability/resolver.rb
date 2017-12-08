# module MongoidAbility
#   class Resolver < Struct.new(:owner, :action, :subject_type, :subject_id, :options)
#     attr_reader :subject_class
#
#     def self.call(*args)
#       new(*args).call
#     end
#
#     def initialize(owner, action, subject_type, subject_id = nil, options = {})
#       super(owner, action, subject_type, subject_id, options)
#
#       @subject_class = subject_type.to_s.constantize
#
#       raise StandardError, "#{subject_type} class does not have default locks" unless @subject_class.respond_to?(:default_locks)
#       raise StandardError, "#{subject_type} class does not have default lock for :#{action} action" unless @subject_class.self_and_ancestors_with_default_locks.any? do |cls|
#         cls.default_locks.any? { |l| l.action == action }
#       end
#     end
#
#     def call
#       raise NotImplementedError
#     end
#   end
# end
