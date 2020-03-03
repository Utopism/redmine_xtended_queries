# encoding: UTF-8

# Smile - adds methods to the Issue model
#
# Mainly TESTED
#
# 1/ module ExtendedQueries
# * #323420 Optimization issues/index
#
# 2/ module VirtualFields
# * #354800 Requête perso demandes : colonne projet mis-à-jour
#   2015


#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module IssueOverride
      #*******************
      # 1/ ExtendedQueries
      module ExtendedQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1/ Instance methods
          b_a_r_and_relay_role_instance_methods = [
            # Smile specific #323420 Optimization issues/index
            :root,                   # 1/ OVERRIDEN Nested Set extended  TESTED  V4.0.0 OK
            :total_estimated_hours,  # 2/ EXTENDED                       PLUGIN  V4.0.0 OK
            :total_spent_hours,      # 3/ REWRITTEN                      PLUGIN  V4.0.0 OK
            # Smile specific #393391 Requête perso Demandes : colonne BU
            :bu_project,             # 4/ new method                     TESTED  V4.0.0 OK
          ]

          trace_prefix       = "#{' ' * (base.name.length + 27)}  --->  "
          last_postfix       = '< (SM::MO::IssueOverride::ExtendedQueries)'

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = b_a_r_and_relay_role_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS            instance_methods  "
          else
            trace_first_prefix = "#{base.name}                 instance_methods  "
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

        # 1/ EXTENDED Nested Set extended, RM 4.0.0 OK
        # Smile specific #323420 Optimization issues/index
        # Smile specific : override of method in redmine/nested_set/traversing.rb
        #                  that does not use association cache
        # cached
        def root
          return @root if defined?(@root)

          @root = super
        end

        # 2/ EXTENDED, RM 4.0.0 OK
        # Smile specific #224825 Totaux colonnes et GLOBAUX pour la requête en cours
        # - The same as parent but cached in any case
        def total_estimated_hours
          @total_estimated_hours ||= super
        end

        # 3/ REWRITTEN, RM 4.0.0 OK
        #
        # Returns the total number of hours spent on this issue and its descendants
        def total_spent_hours
          @total_spent_hours ||= if leaf?
            spent_hours
          else
            self_and_descendants.joins(:time_entries).
              ################
              # Smile specific : hide NOT visible time entries
              joins(:project).
              where( TimeEntry.visible_condition(User.current) ).
              sum("#{TimeEntry.table_name}.hours").
              to_f || 0.0
          end
        end

        # 4/ new method, RM 2.6.1 OK
        # Smile specific #393391 Requête perso Demandes : colonne BU
        def bu_project
          if project.respond_to?('bu_project')
            project.bu_project
          else
            nil
          end
        end
      end # module ExtendedQueries

      #*****************
      # 2/ VirtualFields
      module VirtualFields
        # extend ActiveSupport::Concern
        def self.prepended(base)
          virtual_fields_instance_methods = [
            :project_updated_on, # 1/  TESTED  new method
            :parent_project,     # 2/  TESTED  new method
            :root_subject,       # 3/  TESTED  new method
            :parent_subject,     # 4/  TESTED  new method
            :root_position,      # 5/  TESTED  new method
            :parent_position,    # 6/  TESTED  new method
          ]


          trace_prefix       = "#{' ' * (base.name.length + 27)}  --->  "
          last_postfix       = '< (SM::MO::IssueOverride::VirtualFields)'

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = virtual_fields_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS            instance_methods  "
          else
            trace_first_prefix = "#{base.name}                 instance_methods  "
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

        # 1/ new method, RM 2.6.1 OK
        # Smile specific #354800 Requête perso demandes : colonne projet mis-à-jour
        def project_updated_on
          project.updated_on_from_issues
        end

        # 2/ new method, RM 2.6.1 OK
        # Smile specific #354800 Requête perso demandes : colonne projet mis-à-jour
        def parent_project
          return nil if parent_id.nil?

          parent.project
        end

        # 3/ new method, RM 2.6.1 OK
        # Smile specific #354800 Requête perso demandes : colonne projet mis-à-jour
        def root_subject
          return nil if root_id.nil?

          root.subject
        end

        # 4/ new method, RM 2.6.1 OK
        # Smile specific #354800 Requête perso demandes : colonne projet mis-à-jour
        def parent_subject
          return nil if parent_id.nil?

          parent.subject
        end

        # 5/ new method, RM 4.0.0 OK
        # Smile specific #830767 Issue Query : Sort / Group by parent / root position
        def root_position
          return nil if root_id.nil?

          "#{root.subject} (#{root.position})"
        end

        # 6/ new method, RM 4.0.0 OK
        # Smile specific #830767 Issue Query : Sort / Group by parent / root position
        def parent_position
          return nil if parent_id.nil?

          "#{parent.subject} (#{parent.position})"
        end
      end # module VirtualFields
    end # module IssueOverride
  end # module Models
end # module Smile
