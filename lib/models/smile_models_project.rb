# encoding: UTF-8

# Smile - add methods to the Project model
#
# TESTED
#
# 1/ module ExtendedQueries
# * #354800 Requête perso : filtre projet mis-à-jour
# * #271407 Time Entries : filter by BU
# * #269602 Rapport de temps : critère BU
# * #354800 Requête perso demandes : colonne projet mis-à-jour

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module ProjectOverride
      #*******************
      # 1/ ExtendedQueries
      module ExtendedQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1/ Instance methods
          extended_queries_instance_methods = [
            :is_bu_project?,               # 1/ new method  TESTED
            :bu_project,                   # 2/ new method  TESTED
            :updated_on_from_issues,       # 3/ New method  TESTED
          ]

          trace_prefix       = "#{' ' * (base.name.length + 25)}  --->  "
          last_postfix       = '< (SM::MO::ProjectOverride::ExtendedQueries)'

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
            last_postfix
          )

          if missing_instance_methods.any?
            raise trace_first_prefix + missing_instance_methods.join(', ') + '  ' + last_postfix
          end

          ##################
          # 2) Class methods
          extended_queries_class_methods = [
            :is_bu_project_cf_id,            # 1) new method  TESTED
            :bu_projects_scope,              # 2) new method  TESTED
            :bu_projects,                    # 3) new method  TESTED
          ]

          base.extend ClassMethods

          smile_class_methods = base.methods.select{|m|
              base.method(m).owner == ClassMethods
            }

          missing_class_methods = extended_queries_class_methods.select{|m|
            !smile_class_methods.include?(m)
          }

          if missing_class_methods.any?
            trace_first_prefix = "#{base.name} MISS                   methods  "
          else
            trace_first_prefix = "#{base.name}                        methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_class_methods.any? ?
              missing_class_methods :
              smile_class_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix
          )

          if missing_class_methods.any?
            raise trace_first_prefix + missing_class_methods.join(', ') + '  ' + last_postfix
          end
        end # def self.prepended

        # 1/ new method, RM 2.6 OK
        # Smile specific #269602 Rapport de temps : critère BU
        def is_bu_project?
          return @is_bu_project if defined?(@is_bu_project)

          cf_value = custom_value_for(self.class.is_bu_project_cf_id)
          @is_bu_project = cf_value.present?

          @is_bu_project &&= cf_value.value == '1'

          @is_bu_project
        end

        # 2/ new method, RM 2.6 OK
        # Smile specific #269602 Rapport de temps : criteria BU Project
        def bu_project
          return @bu_project if defined?(@bu_project)

          @bu_project = nil

          self_and_ancestors.each{|p|
            if p.is_bu_project?
              @bu_project = p

              break
            end
          }

          @bu_project
        end

        # 3/ New method, RM 4.0.0 OK
        # Smile specific #354800 Requête perso demandes : colonne projet mis-à-jour
        def updated_on_from_issues
          return @updated_on_from_issues if defined?(@updated_on_from_issues)

          @updated_on_from_issues = nil

          return @updated_on_from_issues if issues.empty?

          # Eager loading !
          issues.each{|i|
            # If issue never updated => updated_on = created_on
            if @updated_on_from_issues
              @updated_on_from_issues = [@updated_on_from_issues, i.updated_on].max
            else
              @updated_on_from_issues = i.updated_on
            end
          }

          @updated_on_from_issues
        end # def updated_on_from_issues

        module ClassMethods
          # 1) new method, RM 4.0.0 OK
          # Smile specific #269602 Rapport de temps : criteria BU Project
          # Constant value
          def is_bu_project_cf_id
            return @@is_bu_project_cf_id if defined?(@@is_bu_project_cf_id)

            @@is_bu_project_cf_id = ProjectCustomField.find_by_name('Est une BU')
            @@is_bu_project_cf_id = @@is_bu_project_cf_id.id if @@is_bu_project_cf_id

            @@is_bu_project_cf_id
          end

          # 2) new method, RM 4.0.0 OK
          # Smile specific #271407 Time Entries : filter by BU Project
          def bu_projects_scope
            CustomValue.where(
                :customized_type => 'Project'
              ).where(
                :custom_field_id => is_bu_project_cf_id
              ).where(
                :value => 1
              ).distinct
          end

          # 3) new method, RM 4.0.0 OK
          # Smile specific #271407 Time Entries : filter by BU
          # Constant value, BUs do not change every day !
          def bu_projects
            return @@bu_projects if defined?(@@bu_projects)

            @@bu_projects = bu_projects_scope.collect{ |cv|
                Project.find_by_id cv.customized_id
              }
          end
        end # module ClassMethods
      end # module ExtendedQueries
    end # module ProjectOverride
  end # module Models
end # module Smile
