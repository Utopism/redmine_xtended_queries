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
            :tracker,                                           #  1/ new method  TESTED  V4.0.0 OK
            :subject,                                           #  2/ new method  TESTED  V4.0.0 OK
            # Nested Set
            :root,                                              #  3/ EXTENDED    TESTED  V4.0.0 OK
            :parent,                                            #  4/ EXTENDED    TESTED  V4.0.0 OK

            :fixed_version,                                     #  5/ EXTENDED    TESTED  V4.0.0 OK
            :category,                                          #  6/ new method  TESTED  V4.0.0 OK
            :issue_id,                                          #  7/ new method  TESTED  V4.0.0 OK

            :estimated_hours,                                   # 20/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_issue_and_user,                    # 21/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_issue,                             # 22/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_user,                              # 23/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_issue_and_user_this_month,         # 24/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_issue_this_month,                  # 25/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_user_this_month,                   # 26/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_issue_and_user_previous_month,     # 27/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_issue_previous_month,              # 28/ new method  TESTED  V4.0.0 OK
            :spent_hours_for_user_previous_month,               # 29/ new method  TESTED  V4.0.0 OK

            :billable_hours_for_issue_and_user,                 # 30/ new method  TESTED  V4.0.0 OK
            :billable_hours_for_issue,                          # 31/ new method  TESTED  V4.0.0 OK
            :billable_hours_for_user,                           # 32/ new method  TESTED  V4.0.0 OK
            :billable_hours_for_issue_and_user_this_month,      # 33/ new method  TESTED  V4.0.0 OK
            :billable_hours_for_issue_this_month,               # 34/ new method  TESTED  V4.0.0 OK
            :billable_hours_for_user_this_month,                # 35/ new method  TESTED  V4.0.0 OK
            :billable_hours_for_issue_and_user_previous_month,  # 36/ new method  TESTED  V4.0.0 OK
            :billable_hours_for_issue_previous_month,           # 37/ new method  TESTED  V4.0.0 OK
            :billable_hours_for_user_previous_month,            # 38/ new method  TESTED  V4.0.0 OK

            :deviation_hours_for_issue_and_user,                # 40/ new method  TESTED  V4.0.0 OK
            :deviation_hours_for_issue,                         # 41/ new method  TESTED  V4.0.0 OK
            :deviation_hours_for_user,                          # 42/ new method  TESTED  V4.0.0 OK
            :deviation_hours_for_issue_and_user_this_month,     # 43/ new method  TESTED  V4.0.0 OK
            :deviation_hours_for_issue_this_month,              # 44/ new method  TESTED  V4.0.0 OK
            :deviation_hours_for_user_this_month,               # 45/ new method  TESTED  V4.0.0 OK
            :deviation_hours_for_issue_and_user_previous_month, # 46/ new method  TESTED  V4.0.0 OK
            :deviation_hours_for_issue_previous_month,          # 47/ new method  TESTED  V4.0.0 OK
            :deviation_hours_for_user_previous_month,           # 48/ new method  TESTED  V4.0.0 OK
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

          return @spent_hours_for_issue_and_user if issue_id.blank? || user_id.blank?

          @spent_hours_for_issue_and_user = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id).
            sum(:hours)
        end

        # 22/ new method, RM 4.0.0 OK
        def spent_hours_for_issue
          return @spent_hours_for_issue if defined?(@spent_hours_for_issue)

          @spent_hours_for_issue = nil

          return @spent_hours_for_issue if issue_id.blank?

          @spent_hours_for_issue = TimeEntry.
            where(:issue_id => self.issue_id).
            sum(:hours)
        end

        # 23/ new method, RM 4.0.0 OK
        def spent_hours_for_user
          return @spent_hours_for_user if defined?(@spent_hours_for_user)

          @spent_hours_for_user = nil

          return @spent_hours_for_user if user_id.blank?

          @spent_hours_for_user = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id).sum(:hours)
        end

        # 24/ new method, RM 4.0.0 OK
        def spent_hours_for_issue_and_user_this_month
          return @spent_hours_for_issue_and_user_this_month if defined?(@spent_hours_for_issue_and_user_this_month)

          @spent_hours_for_issue_and_user_this_month = nil

          return @spent_hours_for_issue_and_user_this_month if issue_id.blank? || user_id.blank?

          date_filter = Date.today

          @spent_hours_for_issue_and_user_this_month = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month).
            sum(:hours)
        end

        # 25/ new method, RM 4.0.0 OK
        def spent_hours_for_issue_this_month
          return @spent_hours_for_issue_this_month if defined?(@spent_hours_for_issue_this_month)

          @spent_hours_for_issue_this_month = nil

          return @spent_hours_for_issue_this_month if issue_id.blank?

          date_filter = Date.today

          @spent_hours_for_issue_this_month = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month).
            sum(:hours)
        end

        # 26/ new method, RM 4.0.0 OK
        def spent_hours_for_user_this_month
          return @spent_hours_for_user_this_month if defined?(@spent_hours_for_user_this_month)

          @spent_hours_for_user_this_month = nil

          return @spent_hours_for_user_this_month if user_id.blank?

          date_filter = Date.today

          @spent_hours_for_user_this_month = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month).
            sum(:hours)
        end

        # 27/ new method, RM 4.0.0 OK
        def spent_hours_for_issue_and_user_previous_month
          return @spent_hours_for_issue_and_user_previous_month if defined?(@spent_hours_for_issue_and_user_previous_month)

          @spent_hours_for_issue_and_user_previous_month = nil

          return @spent_hours_for_issue_and_user_previous_month if issue_id.blank? || user_id.blank?

          date_filter = Date.today.prev_month

          @spent_hours_for_issue_and_user_previous_month = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month).
            sum(:hours)
        end

        # 28/ new method, RM 4.0.0 OK
        def spent_hours_for_issue_previous_month
          return @spent_hours_for_issue_previous_month if defined?(@spent_hours_for_issue_previous_month)

          @spent_hours_for_issue_previous_month = nil

          return @spent_hours_for_issue_previous_month if issue_id.blank?

          date_filter = Date.today.prev_month

          @spent_hours_for_issue_previous_month = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month).
            sum(:hours)
        end

        # 29/ new method, RM 4.0.0 OK
        def spent_hours_for_user_previous_month
          return @spent_hours_for_user_previous_month if defined?(@spent_hours_for_user_previous_month)

          @spent_hours_for_user_previous_month = nil

          return @spent_hours_for_user_previous_month if user_id.blank?

          date_filter = Date.today.prev_month

          @spent_hours_for_user_previous_month = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month).
            sum(:hours)
        end

        # 30/ new method, RM 4.0.0 OK
        def billable_hours_for_issue_and_user
          return @billable_hours_for_issue_and_user if defined?(@billable_hours_for_issue_and_user)

          @billable_hours_for_issue_and_user = nil

          return @billable_hours_for_issue_and_user if issue_id.blank? || user_id.blank?

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_issue_and_user = cf.format.cast_total_value(cf, total)
        end

        # 31/ new method, RM 4.0.0 OK
        def billable_hours_for_issue
          return @billable_hours_for_issue if defined?(@billable_hours_for_issue)

          @billable_hours_for_issue = nil

          return @billable_hours_for_issue if issue_id.blank?

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_issue = cf.format.cast_total_value(cf, total)
        end

        # 32/ new method, RM 4.0.0 OK
        def billable_hours_for_user
          return @billable_hours_for_user if defined?(@billable_hours_for_user)

          @billable_hours_for_user = nil

          return @billable_hours_for_user if user_id.blank?

          scope_for_time_entries = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_user = cf.format.cast_total_value(cf, total)
        end

        # 33/ new method, RM 4.0.0 OK
        def billable_hours_for_issue_and_user_this_month
          return @billable_hours_for_issue_and_user_this_month if defined?(@billable_hours_for_issue_and_user_this_month)

          @billable_hours_for_issue_and_user_this_month = nil

          return @billable_hours_for_issue_and_user_this_month if issue_id.blank? || user_id.blank?

          date_filter = Date.today

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_issue_and_user_this_month = cf.format.cast_total_value(cf, total)
        end

        # 34/ new method, RM 4.0.0 OK
        def billable_hours_for_issue_this_month
          return @billable_hours_for_issue_this_month if defined?(@billable_hours_for_issue_this_month)

          @billable_hours_for_issue_this_month = nil

          return @billable_hours_for_issue_this_month if issue_id.blank?

          date_filter = Date.today

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_issue_this_month = cf.format.cast_total_value(cf, total)
        end

        # 35/ new method, RM 4.0.0 OK
        def billable_hours_for_user_this_month
          return @billable_hours_for_user_this_month if defined?(@billable_hours_for_user_this_month)

          @billable_hours_for_user_this_month = nil

          return @billable_hours_for_user_this_month if user_id.blank?

          date_filter = Date.today

          scope_for_time_entries = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_user_this_month = cf.format.cast_total_value(cf, total)
        end

        # 36/ new method, RM 4.0.0 OK
        def billable_hours_for_issue_and_user_previous_month
          return @billable_hours_for_issue_and_user_previous_month if defined?(@billable_hours_for_issue_and_user_previous_month)

          @billable_hours_for_issue_and_user_previous_month = nil

          return @billable_hours_for_issue_and_user_previous_month if issue_id.blank? || user_id.blank?

          date_filter = Date.today.prev_month

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_issue_and_user_previous_month = cf.format.cast_total_value(cf, total)
        end

        # 37/ new method, RM 4.0.0 OK
        def billable_hours_for_issue_previous_month
          return @billable_hours_for_issue_previous_month if defined?(@billable_hours_for_issue_previous_month)

          @billable_hours_for_issue_previous_month = nil

          return @billable_hours_for_issue_previous_month if issue_id.blank?

          date_filter = Date.today.prev_month

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_issue_previous_month = cf.format.cast_total_value(cf, total)
        end

        # 38/ new method, RM 4.0.0 OK
        def billable_hours_for_user_previous_month
          return @billable_hours_for_user_previous_month if defined?(@billable_hours_for_user_previous_month)

          @billable_hours_for_user_previous_month = nil

          return @billable_hours_for_user_previous_month if user_id.blank?

          date_filter = Date.today.prev_month

          scope_for_time_entries = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.billable_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @billable_hours_for_user_previous_month = cf.format.cast_total_value(cf, total)
        end

        # 40/ new method, RM 4.0.0 OK
        def deviation_hours_for_issue_and_user
          return @deviation_hours_for_issue_and_user if defined?(@deviation_hours_for_issue_and_user)

          @deviation_hours_for_issue_and_user = nil

          return @deviation_hours_for_issue_and_user if user_id.blank?

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_issue_and_user = cf.format.cast_total_value(cf, total)
        end

        # 41/ new method, RM 4.0.0 OK
        def deviation_hours_for_issue
          return @deviation_hours_for_issue if defined?(@deviation_hours_for_issue)

          @deviation_hours_for_issue = nil

          return @deviation_hours_for_issue if issue_id.blank?

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_issue = cf.format.cast_total_value(cf, total)
        end

        # 42/ new method, RM 4.0.0 OK
        def deviation_hours_for_user
          return @deviation_hours_for_user if defined?(@deviation_hours_for_user)

          @deviation_hours_for_user = nil

          return @deviation_hours_for_user if user_id.blank?

          scope_for_time_entries = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_user = cf.format.cast_total_value(cf, total)
        end

        # 43/ new method, RM 4.0.0 OK
        def deviation_hours_for_issue_and_user_this_month
          return @deviation_hours_for_issue_and_user_this_month if defined?(@deviation_hours_for_issue_and_user_this_month)

          @deviation_hours_for_issue_and_user_this_month = nil

          return @deviation_hours_for_issue_and_user_this_month if user_id.blank?

          date_filter = Date.today

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_issue_and_user_this_month = cf.format.cast_total_value(cf, total)
        end

        # 44/ new method, RM 4.0.0 OK
        def deviation_hours_for_issue_this_month
          return @deviation_hours_for_issue_this_month if defined?(@deviation_hours_for_issue_this_month)

          @deviation_hours_for_issue_this_month = nil

          return @deviation_hours_for_issue_this_month if issue_id.blank?

          date_filter = Date.today

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_issue_this_month = cf.format.cast_total_value(cf, total)
        end

        # 45/ new method, RM 4.0.0 OK
        def deviation_hours_for_user_this_month
          return @deviation_hours_for_user_this_month if defined?(@deviation_hours_for_user_this_month)

          @deviation_hours_for_user_this_month = nil

          return @deviation_hours_for_user_this_month if user_id.blank?

          date_filter = Date.today

          scope_for_time_entries = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_user_this_month = cf.format.cast_total_value(cf, total)
        end

        # 46/ new method, RM 4.0.0 OK
        def deviation_hours_for_issue_and_user_previous_month
          return @deviation_hours_for_issue_and_user_previous_month if defined?(@deviation_hours_for_issue_and_user_previous_month)

          @deviation_hours_for_issue_and_user_previous_month = nil

          return @deviation_hours_for_issue_and_user_previous_month if user_id.blank?

          date_filter = Date.today.prev_month

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_issue_and_user_previous_month = cf.format.cast_total_value(cf, total)
        end

        # 47/ new method, RM 4.0.0 OK
        def deviation_hours_for_issue_previous_month
          return @deviation_hours_for_issue_previous_month if defined?(@deviation_hours_for_issue_previous_month)

          @deviation_hours_for_issue_previous_month = nil

          return @deviation_hours_for_issue_previous_month if issue_id.blank?

          date_filter = Date.today.prev_month

          scope_for_time_entries = TimeEntry.
            where(:issue_id => self.issue_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_issue_previous_month = cf.format.cast_total_value(cf, total)
        end

        # 48/ new method, RM 4.0.0 OK
        def deviation_hours_for_user_previous_month
          return @deviation_hours_for_user_previous_month if defined?(@deviation_hours_for_user_previous_month)

          @deviation_hours_for_user_previous_month = nil

          return @deviation_hours_for_user_previous_month if user_id.blank?

          date_filter = Date.today.prev_month

          scope_for_time_entries = TimeEntry.
            where(:project_id => self.project_id).
            where(:user_id => self.user_id).
            where(:tyear => date_filter.year).
            where(:tmonth => date_filter.month)

          cf = self.class.deviation_custom_field
          total = cf.format.total_for_scope(cf, scope_for_time_entries)
          @deviation_hours_for_user_previous_month = cf.format.cast_total_value(cf, total)
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
