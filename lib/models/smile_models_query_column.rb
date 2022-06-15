# Smile - add methods to the QueryColumn model
#
# 1/ module GroupValue
#    brings the group_value method for previous rails versions

module Smile
  module Models
    module QueryColumnOverride
      #**************
      # 1/ GroupValue
      module GroupValue
        def self.prepended(base)
          #####################
          # 1/ Instance methods
          special_group_values_instance_methods = [
            :group_value,        # 1/ EXTENDED            RM 4.0.0 OK
          ]

          trace_prefix = "#{' ' * (base.name.length + 27)}  --->  "
          last_postfix = '< (SM::MO::QueryColumnOverride::GroupValue)'


          smile_instance_methods = base.public_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = special_group_values_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS      instance_methods  "
          else
            trace_first_prefix = "#{base.name}           instance_methods  "
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

        # Returns the group that object belongs to when grouping query results
        def group_value(object)
          val = value(object)
          case name
          when :tmonth, :tweek
            val = "#{object.tyear}-#{val}"
          end
          val
        end
      end # module GroupValue
    end # module QueryColumnOverride
  end # module Models
end # module Smile
