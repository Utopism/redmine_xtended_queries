# Smile - add methods to the QueryCustomFieldColumn model
#
# TESTED
#
# 1/ module ExtendedQueries

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module QueryCustomFieldColumnOverride
      #*******************
      # 1/ ExtendedQueries
      module ExtendedQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1/ Instance methods
          extended_queries_instance_methods = [
            :value_object, # 1/ REWRITTEN  TESTED
          ]

          trace_prefix       = "#{' ' * (base.name.length + 25)}  --->  "
          last_postfix       = '< (SM::MO::QueryCustomFieldColumnOverride::ExtendedQueries)'

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = extended_queries_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS          instance_methods  "
          else
            trace_first_prefix = "#{base.name}               instance_methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_instance_methods.any? ?
              missing_instance_methods :
              smile_instance_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_xtended_queries
          )

          if missing_instance_methods.any?
            raise trace_first_prefix + missing_instance_methods.join(', ') + '  ' + last_postfix
          end
        end # def self.prepended

        # 1/ REWRITTEN, RM 4.0.3 OK
        def value_object(object)
          # Smile specific : to enable User Custom Fields
          # That are always visible
          if !object.respond_to?('project') || (custom_field.visible_by?(object.project, User.current))
            cv = object.custom_values.select {|v| v.custom_field_id == @cf.id}
            cv.size > 1 ? cv.sort {|a,b| a.value.to_s <=> b.value.to_s} : cv.first
          else
            nil
          end
        end

      end # module ExtendedQueries
    end # module QueryCustomFieldColumnOverride
  end # module Models
end # module Smile
