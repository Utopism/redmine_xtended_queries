# Smile - add methods to the Time entry model

# TESTED
#
# 1/ module ExtendedQueries

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module TimeEntryOverride
      #*******************
      # 1/ ExtendedQueries
      module ExtendedQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1/ Instance methods
          extended_queries_instance_methods = [
            :tracker,                            #  1/  new method           TESTED  V4.0.0 OK
            :subject,                            #  2/  new method           TESTED  V4.0.0 OK
            :root,                               #  3/  EXTENDED Nested Set  TESTED  V4.0.0 OK
            :parent,                             #  4/  EXTENDED Nested Set  TESTED  V4.0.0 OK
            :fixed_version,                      #  5/  EXTENDED Nested Set  TESTED  V4.0.0 OK
            :category,                           #  6/  new method           TESTED  V4.0.0 OK
            :issue_id,                           #  7/  new method           TESTED  V4.0.0 OK

            :estimated_hours,                    # 20/  new method           TESTED  V4.0.0 OK
            :spent_hours_for_issue_and_user,     # 21/  new method           TESTED  V4.0.0 OK
            :spent_hours_for_issue,              # 22/  new method           TESTED  V4.0.0 OK
            :spent_hours_for_user,               # 23/  new method           TESTED  V4.0.0 OK
            :billable_hours_for_issue_and_user,  # 24/  new method           TESTED  V4.0.0 OK
            :billable_hours_for_issue,           # 25/  new method           TESTED  V4.0.0 OK
            :billable_hours_for_user,            # 26/  new method           TESTED  V4.0.0 OK
            :deviation_hours_for_issue_and_user, # 27/  new method           TESTED  V4.0.0 OK
            :deviation_hours_for_issue,          # 28/  new method           TESTED  V4.0.0 OK
            :deviation_hours_for_user,           # 29/  new method           TESTED  V4.0.0 OK
          ]


          trace_prefix = "#{' ' * (base.name.length + 23)}  --->  "
          last_postfix = '< (SM::MO::TimeEntryOverride::ExtendedQueries)'

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = extended_queries_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS        instance_methods  "
          else
            trace_first_prefix = "#{base.name}             instance_methods  "
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


          ##################
          # 2/ Class methods
          extended_queries_class_methods = [
            :billable_custom_field_id,   # 1/  new method  TO TEST  RM 4.0.0 OK
            :billable_custom_field,      # 2/  new method  TO TEST  RM 4.0.0 OK
            :deviation_custom_field_id,  # 3/  new method  TO TEST  RM 4.0.0 OK
            :deviation_custom_field,     # 4/  new method  TO TEST  RM 4.0.0 OK
          ]

          base.singleton_class.prepend ClassMethods

          last_postfix = '< (SM::MO::TimeEntryOverride::ExtendedQueries::CMeths)'

          smile_class_methods = base.methods.select{|m|
              base.method(m).owner == ClassMethods
            }

          missing_class_methods = extended_queries_class_methods.select{|m|
            !smile_class_methods.include?(m)
          }

          if missing_class_methods.any?
            trace_first_prefix = "#{base.name} MISS                 methods  "
          else
            trace_first_prefix = "#{base.name}                      methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_class_methods.any? ?
              missing_class_methods :
              smile_class_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_xtended_queries
          )

          if missing_class_methods.any?
            raise trace_first_prefix + missing_class_methods.join(', ') + '  ' + last_postfix
          end
        end # def self.prepended

        # 1/ new method, RM 2.3.2 OK
        # Smile specific #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
        def tracker
          return nil unless issue

          issue.tracker
        end

        # 2/ new method, RM 2.3.2 OK
        # Smile specific #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
        def subject
          return nil unless issue

          issue.subject
        end

        # 3/ EXTENDED Nested Set, RM 4.0.0 OK
        def root
          return @root if defined?(@root)

          @root = nil

          @root = issue.root if issue
        end

        # 4/ EXTENDED Nested Set, RM 4.0.0 OK
        def parent
          return @parent if defined?(@parent)

          @parent = nil

          @parent = issue.parent if issue
        end

        # 5/ new method, RM 4.0.0 OK
        def fixed_version
          return @fixed_version if defined?(@fixed_version)

          @fixed_version = nil

          @fixed_version = issue.fixed_version if issue
        end

        # 6/ new method, RM 4.0.0 OK
        def category
          return @category if defined?(@category)

          @category = nil

          @category = issue.category if issue
        end

        # 7/ New method, RM 4.0.0 OK
        def issue_id
          return @issue_id if defined?(@issue_id)

          @issue_id = nil

          @issue_id = issue.id if issue
        end

        # 20/ new method, RM 4.0.0 OK
        def estimated_hours
          return @estimated_hours if defined?(@estimated_hours)

          @estimated_hours = nil

          @estimated_hours = issue.estimated_hours if issue
        end

        # 21/ new method, RM 4.0.0 OK
        def spent_hours_for_issue_and_user
          return @spent_hours_for_issue_and_user if defined?(@spent_hours_for_issue_and_user)

          @spent_hours_for_issue_and_user = nil

          return @spent_hours_for_issue_and_user if issue_id.blank?
          return @spent_hours_for_issue_and_user if user_id.blank?

          @spent_hours_for_issue_and_user = TimeEntry.where(:issue_id => self.issue_id).where(:user_id => self.user_id).sum(:hours)
        end

        # 22/ new method, RM 4.0.0 OK
        def spent_hours_for_issue
          return @spent_hours_for_issue if defined?(@spent_hours_for_issue)

          @spent_hours_for_issue = nil

          return @spent_hours_for_issue if issue_id.blank?
          return @spent_hours_for_issue if user_id.blank?

          @spent_hours_for_issue = TimeEntry.where(:issue_id => self.issue_id).sum(:hours)
        end

        # 23/ new method, RM 4.0.0 OK
        def spent_hours_for_user
          return @spent_hours_for_user if defined?(@spent_hours_for_user)

          @spent_hours_for_user = nil

          return @spent_hours_for_user if issue_id.blank?
          return @spent_hours_for_user if user_id.blank?

          @spent_hours_for_user = TimeEntry.where(:project_id => self.project_id).where(:user_id => self.user_id).sum(:hours)
        end

        # 24/ new method, RM 4.0.0 OK
        def billable_hours_for_issue_and_user
          return @billable_hours_for_issue_and_user if defined?(@billable_hours_for_issue_and_user)

          @billable_hours_for_issue_and_user = nil

          return @billable_hours_for_issue_and_user if issue_id.blank?
          return @billable_hours_for_issue_and_user if user_id.blank?

          scope_for_time_entries = TimeEntry.where(:project_id => self.project_id).where(:issue_id => self.issue_id).where(:user_id => self.user_id)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_issue_and_user = cf.format.cast_total_value(cf, total)
        end

        # 25/ new method, RM 4.0.0 OK
        def billable_hours_for_issue
          return @billable_hours_for_issue if defined?(@billable_hours_for_issue)

          @billable_hours_for_issue = nil

          return @billable_hours_for_issue if issue_id.blank?
          return @billable_hours_for_issue if user_id.blank?

          scope_for_time_entries = TimeEntry.where(:project_id => self.project_id).where(:issue_id => self.issue_id)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_issue = cf.format.cast_total_value(cf, total)
        end

        # 26/ new method, RM 4.0.0 OK
        def billable_hours_for_user
          return @billable_hours_for_user if defined?(@billable_hours_for_user)

          @billable_hours_for_user = nil

          return @billable_hours_for_user if issue_id.blank?
          return @billable_hours_for_user if user_id.blank?

          scope_for_time_entries = TimeEntry.where(:project_id => self.project_id).where(:user_id => self.user_id)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_user = cf.format.cast_total_value(cf, total)
        end

        # 27/ new method, RM 4.0.0 OK
        def deviation_hours_for_issue_and_user
          return @deviation_hours_for_issue_and_user if defined?(@deviation_hours_for_issue_and_user)

          @deviation_hours_for_issue_and_user = nil

          return @deviation_hours_for_issue_and_user if issue_id.blank?
          return @deviation_hours_for_issue_and_user if user_id.blank?

          scope_for_time_entries = TimeEntry.where(:project_id => self.project_id).where(:issue_id => self.issue_id).where(:user_id => self.user_id)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_issue_and_user = cf.format.cast_total_value(cf, total)
        end

        # 28/ new method, RM 4.0.0 OK
        def deviation_hours_for_issue
          return @deviation_hours_for_issue if defined?(@deviation_hours_for_issue)

          @deviation_hours_for_issue = nil

          return @deviation_hours_for_issue if issue_id.blank?
          return @deviation_hours_for_issue if user_id.blank?

          scope_for_time_entries = TimeEntry.where(:project_id => self.project_id).where(:issue_id => self.issue_id)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_issue = cf.format.cast_total_value(cf, total)
        end

        # 29/ new method, RM 4.0.0 OK
        def deviation_hours_for_user
          return @deviation_hours_for_user if defined?(@deviation_hours_for_user)

          @deviation_hours_for_user = nil

          return @deviation_hours_for_user if issue_id.blank?
          return @deviation_hours_for_user if user_id.blank?

          scope_for_time_entries = TimeEntry.where(:project_id => self.project_id).where(:user_id => self.user_id)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_user = cf.format.cast_total_value(cf, total)
        end

        module ClassMethods
          # 1/ new method, RM 4.0.3 OK
          def billable_custom_field_id
            return @@billable_custom_field_id if defined?(@@billable_custom_field_id)

            @@billable_custom_field_id = TimeEntryCustomField.find_by_name('Billable')
            @@billable_custom_field_id = @@billable_custom_field_id.id if @@billable_custom_field_id

            @@billable_custom_field_id
          end

          # 2/ new method, RM 4.0.3 OK
          def billable_custom_field
            return @@billable_custom_field if defined?(@@billable_custom_field)

            @@billable_custom_field = TimeEntryCustomField.find_by_id(billable_custom_field_id)
          end

          # 3/ new method, RM 4.0.3 OK
          def deviation_custom_field_id
            return @@deviation_custom_field_id if defined?(@@deviation_custom_field_id)

            @@deviation_custom_field_id = TimeEntryCustomField.find_by_name('Deviation')
            @@deviation_custom_field_id = @@deviation_custom_field_id.id if @@deviation_custom_field_id

            @@deviation_custom_field_id
          end

          # 4/ new method, RM 4.0.3 OK
          def deviation_custom_field
            return @@deviation_custom_field if defined?(@@deviation_custom_field)

            @@deviation_custom_field = TimeEntryCustomField.find_by_id(deviation_custom_field_id)
          end
        end # module ClassMethods
      end # module ExtendedQueries
    end # module TimeEntryOverride
  end # module Models
end # module Smile
