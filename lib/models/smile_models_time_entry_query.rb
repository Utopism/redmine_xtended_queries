# Smile - add methods to the Time Entry Query model
#
# TESTED
#
# 1/ module ExtendedQueries
# * #248383 Rapport: filtre sur version et catégorie
#   2014
#
# * #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
#
# * #271407 Time Entries : filter by BU
#   2014
#
# * #358513: Rapport temps passé : filtre Demande Créée (date)
#   2015
#
# * #355842 Rapport temps passé : filtre projet mis-à-jour
#   2015/09

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module TimeEntryQueryOverride
      ####################
      # 1/ ExtendedQueries
      module ExtendedQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1) Instance methods
          extended_queries_instance_methods = [
            :results_scope,                                               #  1/ EXTENDED    TESTED  RM V4.0.0 OK
            :build_from_params,                                           #  2/ EXTENDED    TESTED  RM V4.0.0 OK
            :initialize_available_filters,                                #  3/ REWRITTEN   TO TEST RM V4.0.0 OK
            :available_columns,                                           #  4/ EXTENDED    TESTED  RM V4.0.0 OK
            :joins_additionnal,                                           #  5/ EXTENDED    TO TEST RM V4.0.0 OK
            :joins_for_order_statement,                                   #  6/ EXTENDED    TO TEST RM V4.0.0 OK


            :sql_for_issue_created_on_field,                              # 10/ new method  TESTED  RM V4.0.0 OK
            :sql_for_tracker_field,                                       # 11/ new method  TESTED  RM V4.0.0 OK
            :sql_for_subject_field,                                       # 12/ new method  TESTED  RM V4.0.0 OK
            :sql_for_fixed_version_id_field,                              # 13/ new method  TESTED  RM V4.0.0 OK
            :sql_for_issue_category_id_field,                             # 14/ new method  TESTED  RM V4.0.0 OK
            :sql_for_root_id_field,                                       # 15/ new method  TESTED  RM V4.0.0 OK
            :sql_for_parent_id_field,                                     # 16/ new method  TESTED  RM V4.0.0 OK
            :sql_for_member_of_group_field,                               # 17/ new method  TESTED  RM V4.0.0 OK COPIED from IssueQuery
            :sql_for_user_id_me_field,                                    # 18/ new method  TESTED  RM V4.0.0 OK
            :sql_for_author_id_me_field,                                  # 19/ new method  TESTED  RM V4.0.0 OK

            :sql_for_is_last_time_entry_for_issue_and_user_field,         # 30/ new method  TESTED  RM V4.0.0 OK
            :sql_for_is_last_time_entry_for_issue_field,                  # 31/ new method  TESTED  RM V4.0.0 OK
            :sql_for_is_last_time_entry_for_user_field,                   # 32/ new method  TESTED  RM V4.0.0 OK

            :sql_for_spent_hours_for_issue_and_user_field,                # 33/ new method  TESTED  RM V4.0.0 OK
            :sql_for_spent_hours_for_issue_field,                         # 34/ new method  TESTED  RM V4.0.0 OK
            :sql_for_spent_hours_for_user_field,                          # 35/ new method  TESTED  RM V4.0.0 OK

            :sql_for_spent_hours_for_issue_and_user_this_month_field,     # 36/ new method  TESTED  RM V4.0.0 OK
            :sql_for_spent_hours_for_issue_this_month_field,              # 37/ new method  TESTED  RM V4.0.0 OK
            :sql_for_spent_hours_for_user_this_month_field,               # 38/ new method  TESTED  RM V4.0.0 OK

            :sql_for_spent_hours_for_issue_and_user_previous_month_field, # 39/ new method  TESTED  RM V4.0.0 OK
            :sql_for_spent_hours_for_issue_previous_month_field,          # 40/ new method  TESTED  RM V4.0.0 OK
            :sql_for_spent_hours_for_user_previous_month_field,           # 41/ new method  TESTED  RM V4.0.0 OK


            #################################################
            # New filters on last time entry for issue / user
            :join_max_time_entry_id_by_issue_and_user_needed_for_filters?,                # 50/ new TO TEST RM V4.0.0 OK
            :join_max_time_entry_id_by_issue_needed_for_filters?,                         # 51/ new method  TO TEST RM V4.0.0 OK
            :join_max_time_entry_id_by_user_needed_for_filters?,                          # 52/ new method  TO TEST RM V4.0.0 OK

            ############################
            # New filters on Spent hours
            :join_max_time_entry_id_by_issue_and_user_this_month_needed_for_filters?,     # 53/ new TO TEST RM V4.0.0 OK
            :join_max_time_entry_id_by_issue_this_month_needed_for_filters?,              # 54/ new method  TO TEST RM V4.0.0 OK
            :join_max_time_entry_id_by_user_this_month_needed_for_filters?,               # 55/ new method  TO TEST RM V4.0.0 OK

            :join_max_time_entry_id_by_issue_and_user_previous_month_needed_for_filters?, # 56/ new TO TEST RM V4.0.0 OK
            :join_max_time_entry_id_by_issue_previous_month_needed_for_filters?,          # 57/ new method  TO TEST RM V4.0.0 OK
            :join_max_time_entry_id_by_user_previous_month_needed_for_filters?,           # 58/ new method  TO TEST RM V4.0.0 OK

            :total_for_spent_hours_for_issue,                      # 60/ new method  TO TEST RM V4.0.0 OK
            :total_for_spent_hours_for_issue_and_user,             # 61/ new method  TO TEST RM V4.0.0 OK
            :total_for_spent_hours_for_user,                       # 62/ new method  TO TEST RM V4.0.0 OK
            :total_for_billable_hours_for_issue,                   # 63/ new method  TO TEST RM V4.0.0 OK
            :total_for_billable_hours_for_issue_and_user,          # 64/ new method  TO TEST RM V4.0.0 OK
            :total_for_billable_hours_for_user,                    # 65/ new method  TO TEST RM V4.0.0 OK
            :total_for_deviation_hours_for_issue,                  # 66/ new method  TO TEST RM V4.0.0 OK
            :total_for_deviation_hours_for_issue_and_user,         # 67/ new method  TO TEST RM V4.0.0 OK
            :total_for_deviation_hours_for_user,                   # 68/ new method  TO TEST RM V4.0.0 OK
          ]

          trace_prefix = "#{' ' * (base.name.length + 18)}  --->  "
          last_postfix = '< (SM::MO::TimeEntryQueryOverride::ExtendedQueries)'

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          smile_instance_methods += base.private_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = extended_queries_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS   instance_methods  "
          else
            trace_first_prefix = "#{base.name}        instance_methods  "
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

          ########################
          # 2/ New safe_attributes
          base.instance_eval do
            ################
            # Smile specific #340206 Filtre additifs
            include Redmine::SafeAttributes

            safe_attributes 'or_filters'
            serialize :or_filters
            # END -- Smile specific #340206 Filtre additifs
            #######################
          end

          trace_first_prefix = "#{base.name}         safe_attributes  "

          SmileTools::trace_by_line(
            (
              ['+ or_filters']
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_xtended_queries
          )


          ##################
          # 3) Query Columns
          new_query_columns_names = [
            :id,
            :issue,
            :issue_id,
            :spent_hours_for_issue_and_user,
            :spent_hours_for_issue,
            :spent_hours_for_user,
            :spent_hours_for_issue_and_user_this_month,
            :spent_hours_for_issue_this_month,
            :spent_hours_for_user_this_month,
            :spent_hours_for_issue_and_user_previous_month,
            :spent_hours_for_issue_previous_month,
            :spent_hours_for_user_previous_month,
            :root,
            :parent,
            :tracker,
            :fixed_version,
            :category,
            :subject,
          ]

          if TimeEntry.billable_custom_field_id
            new_query_columns_names += [
              :billable_hours_for_issue_and_user,
              :billable_hours_for_issue,
              :billable_hours_for_user,
              :billable_hours_for_issue_and_user_this_month,
              :billable_hours_for_issue_this_month,
              :billable_hours_for_user_this_month,
              :billable_hours_for_issue_and_user_previous_month,
              :billable_hours_for_issue_previous_month,
              :billable_hours_for_user_previous_month,
            ]
          end

          if TimeEntry.deviation_custom_field_id
            new_query_columns_names += [
              :deviation_hours_for_issue_and_user,
              :deviation_hours_for_issue,
              :deviation_hours_for_user,
              :deviation_hours_for_issue_and_user_this_month,
              :deviation_hours_for_issue_this_month,
              :deviation_hours_for_user_this_month,
              :deviation_hours_for_issue_and_user_previous_month,
              :deviation_hours_for_issue_previous_month,
              :deviation_hours_for_user_previous_month,
            ]
          end

          # Smile specific : + Issue ID column sortable + groupable
          base.available_columns.unshift(
            QueryColumn.new(:issue_id, :sortable => "#{Issue.table_name}.id", :default_order => 'desc', :caption => :field_issue_id, :groupable => "#{Issue.table_name}.id")
          )

          # Smile specific : Issue column + groupable
          issue_column = base.available_columns.detect{|c| c.name == :issue}
          if issue_column
            # To enable groupable
            issue_column.groupable = "#{Issue.table_name}.id"
          end

          # Smile specific : + ID column + sortable + groupable
          base.available_columns.unshift(
            QueryColumn.new(:id, :sortable => "#{TimeEntry.table_name}.id", :default_order => 'desc', :caption => '#', :frozen => true, :groupable => "#{Issue.table_name}.id")
          )

          base.available_columns << QueryColumn.new(:estimated_hours, :sortable => "#{Issue.table_name}.estimated_hours", :groupable => "#{Issue.table_name}.estimated_hours")

          # Spent Hours for Issue / User
          base.available_columns << QueryColumn.new(:spent_hours_for_issue_and_user, :sortable => "hours", :totalable => true)
          base.available_columns << QueryColumn.new(:spent_hours_for_issue, :sortable => "hours", :totalable => true)
          base.available_columns << QueryColumn.new(:spent_hours_for_user, :sortable => "hours", :totalable => true)

          base.available_columns << QueryColumn.new(:spent_hours_for_issue_and_user_this_month, :sortable => "hours", :totalable => false)
          base.available_columns << QueryColumn.new(:spent_hours_for_issue_this_month, :sortable => "hours", :totalable => false)
          base.available_columns << QueryColumn.new(:spent_hours_for_user_this_month, :sortable => "hours", :totalable => false)

          base.available_columns << QueryColumn.new(:spent_hours_for_issue_and_user_previous_month, :sortable => "hours", :totalable => false)
          base.available_columns << QueryColumn.new(:spent_hours_for_issue_previous_month, :sortable => "hours", :totalable => false)
          base.available_columns << QueryColumn.new(:spent_hours_for_user_previous_month, :sortable => "hours", :totalable => false)

          # Billable Hours for Issue / User
          if TimeEntry.billable_custom_field_id
            base.available_columns << QueryColumn.new(:billable_hours_for_issue_and_user, :sortable => "hours", :totalable => true)
            base.available_columns << QueryColumn.new(:billable_hours_for_issue, :sortable => "hours", :totalable => true)
            base.available_columns << QueryColumn.new(:billable_hours_for_user, :sortable => "hours", :totalable => true)

            base.available_columns << QueryColumn.new(:billable_hours_for_issue_and_user_this_month, :sortable => "hours", :totalable => false)
            base.available_columns << QueryColumn.new(:billable_hours_for_issue_this_month, :sortable => "hours", :totalable => false)
            base.available_columns << QueryColumn.new(:billable_hours_for_user_this_month, :sortable => "hours", :totalable => false)

            base.available_columns << QueryColumn.new(:billable_hours_for_issue_and_user_previous_month, :sortable => "hours", :totalable => false)
            base.available_columns << QueryColumn.new(:billable_hours_for_issue_previous_month, :sortable => "hours", :totalable => false)
            base.available_columns << QueryColumn.new(:billable_hours_for_user_previous_month, :sortable => "hours", :totalable => false)
          end

          # Deviation Hours for Issue / User
          if TimeEntry.deviation_custom_field_id
            base.available_columns << QueryColumn.new(:deviation_hours_for_issue_and_user, :sortable => "hours", :totalable => true)
            base.available_columns << QueryColumn.new(:deviation_hours_for_issue, :sortable => "hours", :totalable => true)
            base.available_columns << QueryColumn.new(:deviation_hours_for_user, :sortable => "hours", :totalable => true)

            base.available_columns << QueryColumn.new(:deviation_hours_for_issue_and_user_this_month, :sortable => "hours", :totalable => false)
            base.available_columns << QueryColumn.new(:deviation_hours_for_issue_this_month, :sortable => "hours", :totalable => false)
            base.available_columns << QueryColumn.new(:deviation_hours_for_user_this_month, :sortable => "hours", :totalable => false)

            base.available_columns << QueryColumn.new(:deviation_hours_for_issue_and_user_previous_month, :sortable => "hours", :totalable => false)
            base.available_columns << QueryColumn.new(:deviation_hours_for_issue_previous_month, :sortable => "hours", :totalable => false)
            base.available_columns << QueryColumn.new(:deviation_hours_for_user_previous_month, :sortable => "hours", :totalable => false)
          end

          ################
          # Smile specific #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
          # Smile specific #751023 V4.0.0 : Time entries list : Root Parent Task columns
          # + ROOT groupable
          base.available_columns << QueryColumn.new(
            :root,
            :sortable => "#{Issue.table_name}.root_id",
            :caption => :field_issue_root_id,
            :groupable => "#{Issue.table_name}.root_id"
          )

          # Smile specific #751023 V4.0.0 : Time entries list : Root and Parent Task columns
          # + PARENT groupable
          base.available_columns << QueryColumn.new(
            :parent,
            :sortable => "#{Issue.table_name}.parent_id",
            :caption => :field_issue_parent_id,
            :groupable => "#{Issue.table_name}.parent_id"
          )

          # Add columns tracker and subject, that were included in issue column before
          # TRACKER : + groupable
          tracker_column = base.available_columns.detect{|c| c.name == :'issue.tracker'}
          # QueryAssociationColumn -> QueryColumn to enable groupable
          if tracker_column
            base.available_columns.delete(tracker_column)
          end

          base.available_columns << QueryColumn.new(:tracker, :sortable => "#{Issue.table_name}.tracker_id", :groupable => "#{Issue.table_name}.tracker_id")

          # Add columns tracker and subject, that were included in issue column before
          # + VERSION
          # :groupable => true
          base.available_columns << QueryColumn.new(:fixed_version, :sortable => "#{Issue.table_name}.fixed_version_id", :groupable => "#{Issue.table_name}.fixed_version_id")

          # Add columns tracker and subject, that were included in issue column before
          # CATEGORY : + groupable
          category_column = base.available_columns.detect{|c| c.name == :'issue.category'}
          # QueryAssociationColumn -> QueryColumn to enable groupable
          if category_column
            base.available_columns.delete(category_column)
          end

          base.available_columns << QueryColumn.new(:category, :sortable => "#{IssueCategory.table_name}.name", :groupable => "#{IssueCategory.table_name}.name")

          # + SUBJECT
          base.available_columns << QueryColumn.new(:subject, :sortable => "#{Issue.table_name}.subject")
          # END -- Smile specific #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
          #######################

          ################
          # Smile specific : + UserCustomField columns for Time Entries list
          base.available_columns += UserCustomField.all.
                            map {|cf| QueryAssociationCustomFieldColumn.new(:user, cf) }

          current_query_columns_names = base.available_columns.select{|ac| new_query_columns_names.include?(ac.name)}.collect(&:name)

          missing_query_columns_names = new_query_columns_names.select{|ac|
              ! current_query_columns_names.include?(ac)
            }

          if missing_query_columns_names.any?
            trace_first_prefix = "#{base.name} MISS  available_columns  "
          else
            trace_first_prefix = "#{base.name}       available_columns  "
          end

          SmileTools::trace_by_line(
            (
              missing_query_columns_names.any? ?
              missing_query_columns_names :
              new_query_columns_names
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_xtended_queries
          )

          if missing_query_columns_names.any?
            raise trace_first_prefix + missing_query_columns_names.join(', ') + '  ' + last_postfix
          end


          ##################
          # 4) Class methods
          extended_queries_class_methods = [
            # New filter on last time entry for issue / user
            :sql_max_time_entry_id_by_issue_and_user,        #  1/ REWRITTEN,  TO TEST RM V4.0.0 OK
            :sql_max_time_entry_id_by_issue,                 #  2/ REWRITTEN,  TO TEST RM V4.0.0 OK
            :sql_max_time_entry_id_by_user,                  #  3/ REWRITTEN,  TO TEST RM V4.0.0 OK

            :left_join_max_time_entry_id_by_issue_and_user,  #  4/ new method  TO TEST RM V4.0.0 OK
            :left_join_max_time_entry_id_by_issue,           #  5/ new method  TO TEST RM V4.0.0 OK
            :left_join_max_time_entry_id_by_user,            #  6/ new method  TO TEST RM V4.0.0 OK

            :joins_for_bu_project_id,                        # 10/ new method  TO TEST RM V4.0.0 OK
          ]

          last_postfix = '< (SM::MO::TimeEntryQueryOverride::ExtendedQueries::CMeths)'

          base.singleton_class.prepend ClassMethods


          smile_class_methods = base.methods.select{|m|
              base.method(m).owner == ClassMethods
            }

          missing_class_methods = extended_queries_class_methods.select{|m|
            !smile_class_methods.include?(m)
          }

          if missing_class_methods.any?
            trace_first_prefix = "#{base.name} MISS            methods  "
          else
            trace_first_prefix = "#{base.name}                 methods  "
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


        # 1/ EXTENDED, RM 4.0.0 Plugin OK
        # Smile specific #248383 Rapport: filtre sur version et catégorie
        # Smile specific #358513 Filtre Demande Mise-à-jour
        # Smile specific #423277 Rapport : Filtre sur tâche parente et racine
        # Smile specific #271407 Time Entries : filter by BU
        # Smile specific #355842 Rapport temps passé : filtre projet mis-à-jour
        def results_scope(options={})
          ################
          # Smile specific : scope stored for later modification
          scope_for_results = super

          ################
          # Smile specific #248383 Rapport: filtre sur version et catégorie
          # Smile specific #358513 Filtre Demande Mise-à-jour
          # Smile specific #423277 Rapport : Filtre sur tâche parente et racine
          if (
              filters.include?('fixed_version_id') ||
              filters.include?('category_id') ||
              filters.include?('issue_created_on') ||
              filters.include?('parent_id') ||
              filters.include?('root_id')
          )
            # Do not includes issue, generate a conflicting second join on issues
            #scope_for_results = scope_for_results.includes(:issue)
          end
          # END -- Smile specific #248383 Rapport: filtre sur version et catégorie
          #######################

          ################
          # Smile specific #271407 Time Entries : filter by BU
          if filters.include?('bu_project')
            scope_for_results = scope_for_results.joins(
                self.class.joins_for_bu_project_id
              )

          end
          # END -- Smile specific #271407 Time Entries : filter by BU
          #######################

          ################
          # Smile specific #355842 Rapport temps passé : filtre projet mis-à-jour
          if filters.include?('project_updated_on')
            sql_projects_filter = filter_column_on_projects('project_id')

            unless sql_projects_filter.present?
              sql_projects_filter = '(1=1)'
            end

            scope_for_results = scope_for_results.joins(
                self.class.left_join_project_updated_on_from_issues(sql_projects_filter)
              )
          end
          # END -- Smile specific #355842 Rapport temps passé : filtre projet mis-à-jour
          #######################

          scope_for_results
        end

        # 2/ EXTENDED, RM 4.0.0 Plugin OK
        # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
        # Smile specific #340206 Filtre additifs
        #
        # Accepts :from/:to params as shortcut filters
        def build_from_params(params, defaults={})
          ################
          # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
          # Smile specific : with_children option
          if self.respond_to?('with_children')
            self.with_children = params[:with_children] ||
              (params[:query] && params[:query][:with_children]) ||
              params[:sum_time] ||
              (params[:query] && params[:query][:sum_time])
          end

          ################
          # Smile specific : group_additional_infos option
          if self.respond_to?('group_additional_infos')
            self.group_additional_infos = params[:group_additional_infos] ||
              (params[:query] && params[:query][:group_additional_infos])
          end

          ################
          # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
          if self.respond_to?('advanced_filters')
            self.advanced_filters = params[:advanced_filters] || (params[:query] && params[:query][:advanced_filters])
          end

          ################
          # Smile specific #277485 Rapport : Export Csv, option conversion en jours
          # Smile specific : hours_by_day option
          if self.respond_to?('hours_by_day')
            self.hours_by_day = params[:hours_by_day] || (params[:query] && params[:query][:hours_by_day])
          end

          ################
          # Smile specific #340206 Filtre additifs
          if params[:or_fields] || params[:or_f]
            self.or_filters = {}
            add_or_filters(params[:or_fields] || params[:or_f], params[:or_operators] || params[:or_op], params[:or_values] || params[:or_v])
          # else
            # field short filters already added in super method
          end
          # END -- Smile specific
          #######################

          if Redmine::VERSION::MAJOR < 4
            super(params)
          else
            super(params, defaults)
          end

          self
        end

        # 3/ REWRITTEN, RM 4.0.0 OK
        # Smile specific #768560: V4.0.0 : Time entries list : access to hidden BAR values
        # Smile specific #994 Budget and Remaining enhancement
        # Smile specific : new filters
        # + BU
        # + PROJECT UPDATED ON
        # + ROOT_ID, PARENT_ID
        # + ISSUE CREATED ON
        # + MEMBER OF GROUP
        # TODO move to hook budget/remaining hours :
        # + BUDGET HOURS
        # + REMAINING HOURS
        def initialize_available_filters
          add_available_filter "spent_on", :type => :date_past

          add_available_filter("project_id",
            :type => :list, :values => lambda { project_values }
          ) if project.nil?

          if project && !project.leaf?
            ################
            # Smile specific #768560: V4.0.0 : Time entries list : access to hidden BAR values
            # Smile specific : subproject_values + current project param
            add_available_filter "subproject_id",
              :type => :list_subprojects,
              :values => lambda { subproject_values(true) }
          end

          ################
          # Smile specific #271407 Time Entries : filter by BU
          # + BU
          unless project
            bu_projects = Project.bu_projects.sort

            if bu_projects.any?
              add_available_filter "bu_project",
                :label => :label_bu,
                :type => :list_optional,
                :values => ( bu_projects.collect{|p| [p.name, p.id.to_s]} )
            end
          end
          # END -- Smile specific #271407 Time Entries : filter by BU
          #######################

          ################
          # Smile specific #355842 Rapport temps passé : filtre projet mis-à-jour
          # No way to filter projects of sub-request for project_updated_on, if no project
          # + PROJECT UPDATED ON
          add_available_filter('project_updated_on',
            :type => :date_past,
            :name => "#{l(:label_project)} #{l(:field_updated_on)}"
          ) if project
          # END -- Smile specific #355842 Rapport temps passé : filtre projet mis-à-jour
          #######################

          ################
          # Smile specific : new filters, only if on project
          # Smile comment : Too heavy for all projects query
          if advanced_filters
            if project
              ################
              # Smile specific #423277 Rapport : Filtre sur tâche parente et racine
              # + ROOT_ID, PARENT_ID
              add_available_filter 'root_id',
                :name => l('field_issue_root_id'),
                :type => :list_optional,
                :values => lambda {
                  calc_project_and_children_issues
                    @children_root_issues_id_and_label
                }

              add_available_filter 'parent_id',
                :name => l('field_issue_parent_id'),
                :type => :list_optional,
                :values => lambda {
                  calc_project_and_children_issues
                    @children_parent_issues_id_and_label
                }

              ################
              # Smile specific #247451 Entrées de temps et Rapport : filtre par demande
              # * Unable to know if we are on an issue :
              #   scope modified afterwards by the controller to filter on issue
              #   => possible to filter on an issue that is not the current one
              #   => obviously will return no result
              # + ISSUE_ID
              add_available_filter 'issue_id',
                :type => :list_optional,
                :values => lambda {
                  calc_project_and_children_issues
                    @children_issues_id_and_label
                }
              # END -- Smile specific #247451 Entrées de temps et Rapport : filtre par demande
              #######################

              #---------------
              # Smile specific #147568 Filter on parent task
              # children_count
              # Works even if NO project specified
              add_available_filter 'children_count', :type => :integer

              #---------------
              # Smile specific #226967 Filter 'number of parents'
              add_available_filter 'level_in_tree',
                :type => :integer
            end
          else
            # NATIVE source code
            add_available_filter("issue_id", :type => :tree, :label => :label_issue)
          end
          # END -- Smile specific : new filters, only if on project
          #######################


          ################
          # Smile specific : issue created on filter
          # + ISSUE CREATED ON
          add_available_filter "issue_created_on", :type => :date_past, :name =>"#{l(:field_issue)} #{l(:field_created_on)}"

          add_available_filter("issue.tracker_id",
            :type => :list,
            :name => l("label_attribute_of_issue", :name => l(:field_tracker)),
            :values => lambda { trackers.map {|t| [t.name, t.id.to_s]} })
          add_available_filter("issue.status_id",
            :type => :list,
            :name => l("label_attribute_of_issue", :name => l(:field_status)),
            :values => lambda { issue_statuses_values })
          add_available_filter("issue.fixed_version_id",
            :type => :list,
            :name => l("label_attribute_of_issue", :name => l(:field_fixed_version)),
            :values => lambda { fixed_version_values })
          add_available_filter "issue.category_id",
            :type => :list_optional,
            :name => l("label_attribute_of_issue", :name => l(:field_category)),
            :values => lambda { project.issue_categories.collect{|s| [s.name, s.id.to_s] } } if project

          add_available_filter("user_id",
            :type => :list_optional, :values => lambda { author_values }
          )

          ################
          # Smile specific #831010: Time Report Query : new time entry user filter, me
          if User.current.logged?
            add_available_filter("user_id_me",
              :type => :list_optional, :values => lambda { [["<< #{l(:label_me)} >>", 'me']] }, :name =>"#{l(:field_user)} (#{l(:label_me)})"
            )
          end

          ################
          # Smile specific : starting from Redmine ~ 4
          if TimeEntry.instance_methods.include?(:author)
            add_available_filter("author_id",
              :type => :list_optional, :values => lambda { author_values }
            )
          end

          ################
          # Smile specific #831010: Time Report Query : new time entry user filter, me
          # + AUTHOR_ID_ME
          if Redmine::VERSION::MAJOR >= 4
            if User.current.logged?
              add_available_filter("author_id_me",
                :type => :list_optional, :values => lambda { [["<< #{l(:label_me)} >>", 'me']] }, :name =>"#{l(:field_author)} (#{l(:label_me)})"
              )
            end
          end

          ################
          # Smile specific #473776 Spent Time Report : Filter on Assignee's group
          # + MEMBER OF GROUP
          add_available_filter("member_of_group",
            :type => :list_optional, :values => lambda { Group.givable.order(:lastname).collect {|g| [g.name, g.id.to_s]} }
          )
          # END -- Smile specific #473776 Spent Time Report : Filter on Assignee's group
          #######################

          activities = (project ? project.activities : TimeEntryActivity.shared)
          add_available_filter("activity_id",
            :type => :list, :values => activities.map {|a| [a.name, a.id.to_s]}
          )

          add_available_filter("project.status",
            :type => :list,
            :name => l(:label_attribute_of_project, :name => l(:field_status)),
            :values => lambda { project_statuses_values }
          ) if project.nil? || !project.leaf?

          add_available_filter "comments", :type => :text

          ################
          # Smile specific #994 Budget and Remaining enhancement
          # If we display all issue, display budget_hours and remaining_hours columns
          # + BUDGET HOURS
          budget_and_remaining_enabled = Project.respond_to?('b_a_r_module') &&
            ( self.project.nil? || self.project.budget_and_remaining_enabled )

          add_available_filter "budget_hours", :type => :float if budget_and_remaining_enabled
          # END -- Smile specific #994 Budget and Remaining enhancement
          #######################

          add_available_filter "hours", :type => :float

          add_available_filter "spent_hours_for_issue_and_user",                :type => :float
          add_available_filter "spent_hours_for_issue",                         :type => :float
          add_available_filter "spent_hours_for_user",                          :type => :float

          add_available_filter "spent_hours_for_issue_and_user_this_month",     :type => :float
          add_available_filter "spent_hours_for_issue_this_month",              :type => :float
          add_available_filter "spent_hours_for_user_this_month",               :type => :float

          add_available_filter "spent_hours_for_issue_and_user_previous_month", :type => :float
          add_available_filter "spent_hours_for_issue_previous_month",          :type => :float
          add_available_filter "spent_hours_for_user_previous_month",           :type => :float

          ################
          # Smile specific #994 Budget and Remaining enhancement
          # + REMAINING HOURS
          add_available_filter "remaining_hours", :type => :float if budget_and_remaining_enabled
          # END -- Smile specific #994 Budget and Remaining enhancement
          #######################

          #################
          # Added by plugin
          list_yes_no =
            [
              [l(:general_text_Yes), '1'], # index must be a string !
              [l(:general_text_No),  '0'],
            ]

          add_available_filter "is_last_time_entry_for_issue_and_user", :type => :list_optional, :values => list_yes_no
          add_available_filter "is_last_time_entry_for_issue", :type => :list_optional, :values => list_yes_no
          add_available_filter "is_last_time_entry_for_user", :type => :list_optional, :values => list_yes_no

          add_custom_fields_filters(TimeEntryCustomField)
          add_associations_custom_fields_filters :project
          add_custom_fields_filters(issue_custom_fields, :issue)
          add_associations_custom_fields_filters :user
        end

        # 4/ EXTENDED, RM 4.0.0 OK
        # Add new optional columns
        # instance variable : for each project / user
        # + TYEAR
        # + TMONTH
        #   TWEEK + groupable
        def available_columns
          super

          index_tyear = @available_columns.find_index {|column| column.name == :tyear}

          # Already overriden
          return @available_columns if index_tyear

          ################
          # Smile Specific #379708 Liste entrées de temps : colonne semaine

          index = @available_columns.find_index {|column| column.name == :tweek}

          # + TYEAR
          # spent_on_column = base.available_columns.detect{|c| c.name == :spent_on}
          @available_columns.insert (index + 1), QueryColumn.new(:tyear,
              :sortable => ["#{TimeEntry.table_name}.spent_on", "#{TimeEntry.table_name}.created_on"],
              :groupable => true,
              :caption => l(:label_year)
            )

          # + TMONTH
          @available_columns.insert (index + 1), QueryColumn.new(:tmonth,
              :sortable => ["#{TimeEntry.table_name}.spent_on", "#{TimeEntry.table_name}.created_on"],
              :groupable => true,
              :caption => l(:label_month)
            )

          # TWEEK : groupable
          tweek_column = @available_columns.detect{|c| c.name == :tweek}

          if tweek_column
           tweek_column.groupable = "#{TimeEntry.table_name}.tweek"
          end
          # END -- Smile Specific #379708 Liste entrées de temps : colonne semaine
          #######################

          @available_columns
        end

        # 5/ Extended, RM 4.0.0 OK
        # Smile specific : debug from query
        # Smile specific : + join_max_t_e_by_issue / user
        # Smile specific : + join_max_t_e_by_issue / user -- this month
        # Smile specific : + join_max_t_e_by_issue / user -- previous month
        def joins_additionnal(order_options)
          joins = super

          debug = nil
          if self.respond_to?('debug')
            debug = self.debug
          end

          logger.debug " =>prof         joins_additionnal" if debug
          logger.debug " =>prof           group_by_column=#{group_by_column.name}" if group_by_column && debug
          logger.debug " =>prof           filters=#{self.filters}" if debug == '2'


          ######
          # 1.0) join max t.e. by issue / user
          join_max_t_e_by_issue_and_user                = join_max_time_entry_id_by_issue_and_user_needed_for_filters?
          join_max_t_e_by_issue                         = join_max_time_entry_id_by_issue_needed_for_filters?
          join_max_t_e_by_user                          = join_max_time_entry_id_by_user_needed_for_filters?

          ######
          # 2.0) join max t.e. by issue / user THIS MONTH
          join_max_t_e_by_issue_and_user_this_month     = join_max_time_entry_id_by_issue_and_user_this_month_needed_for_filters?
          join_max_t_e_by_issue_this_month              = join_max_time_entry_id_by_issue_this_month_needed_for_filters?
          join_max_t_e_by_user_this_month               = join_max_time_entry_id_by_user_this_month_needed_for_filters?

          ######
          # 3.0) join max t.e. by issue / user PREVIOUS MONTH
          join_max_t_e_by_issue_and_user_previous_month = join_max_time_entry_id_by_issue_and_user_previous_month_needed_for_filters?
          join_max_t_e_by_issue_previous_month          = join_max_time_entry_id_by_issue_previous_month_needed_for_filters?
          join_max_t_e_by_user_previous_month           = join_max_time_entry_id_by_user_previous_month_needed_for_filters?

          sql_visible_issues_filter = nil

          # 0) Filter on VISIBLE sub-issues used in left_join_max_time_entry_id_by_issue / user
          #    ALL / THIS MONTH / PREVIOUS MONTH
          if (
            join_max_t_e_by_issue_and_user ||
            join_max_t_e_by_issue ||
            join_max_t_e_by_user ||

            join_max_t_e_by_issue_and_user_this_month ||
            join_max_t_e_by_issue_this_month ||
            join_max_t_e_by_user_this_month ||

            join_max_t_e_by_issue_and_user_previous_month ||
            join_max_t_e_by_issue_previous_month ||
            join_max_t_e_by_user_previous_month
          )
            sql_visible_issues_filter = ' ' + self.class.sql_in_values_or_false_if_empty(
              sql_visible_time_entries_issues_ids(
                filter_column_on_projects('project_id'),
                debug
              ),
              'issue_id'
            )

            logger.debug " =>prof           sql_visible_issues_filter=#{sql_visible_issues_filter}" if debug == '3'
          end


          ####
          # 1) join max t.e. by issue / user
          if (
            join_max_t_e_by_issue_and_user ||
            join_max_t_e_by_issue ||
            join_max_t_e_by_user
          )
            #-----------------------
            # 1.1) By Issue and User, Filter on visible time entries
            if join_max_t_e_by_issue_and_user
              logger.debug " =>prof           +left_join_max_time_entry_id_by_issue_and_user(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # Access to time entries check
                  sql_visible_issues_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_issue_and_user(sql_where_filter)
            else
              logger.debug " =>prof           join_max_time_entry_by_issue_and_user NOT needed" if debug == '2'
            end

            #--------------
            # 1.2) By Issue, Filter on visible time entries
            if join_max_t_e_by_issue
              logger.debug " =>prof           +left_join_max_time_entry_id_by_issue(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # 1.1) Access to time entries check
                  sql_visible_issues_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_issue(sql_where_filter)
            else
              logger.debug " =>prof           join_max_time_entry_by_issue          NOT needed" if debug == '2'
            end

            #-------------
            # 1.3) By User, Filter on visible time entries
            if join_max_t_e_by_user
              logger.debug " =>prof           +left_join_max_time_entry_id_by_user(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # Access to time entries check
                  sql_visible_issues_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_user(sql_where_filter)
            else
              logger.debug " =>prof           join_max_time_entry_by_user           NOT needed" if debug == '2'
            end
          end


          ####
          # 2) join max t.e. by issue / user THIS MONTH
          if (
            join_max_t_e_by_issue_and_user_this_month ||
            join_max_t_e_by_issue_this_month ||
            join_max_t_e_by_user_this_month
          )
            #------------------------------------------
            # 2.0) Filter time entries on current month
            date_filter = Date.today
            #date_filter = Date.today.prev_month
            sql_current_month_t_e_filter = "tyear = #{date_filter.year} AND tmonth = #{date_filter.month}"

            #-----------------------
            # 2.1) By Issue and User, Filter on visible time entries
            if join_max_t_e_by_issue_and_user_this_month
              logger.debug " =>prof           +left_join_max_time_entry_id_by_issue_and_user(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # Access to time entries check
                  sql_visible_issues_filter,
                  sql_current_month_t_e_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_issue_and_user(sql_where_filter, '_this_month')
            else
              logger.debug " =>prof           join_max_time_entry_by_issue_and_user NOT needed" if debug == '2'
            end

            #--------------
            # 2.2) By Issue, Filter on visible time entries
            if join_max_t_e_by_issue_this_month
              logger.debug " =>prof           +left_join_max_time_entry_id_by_issue(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # Access to time entries check
                  sql_visible_issues_filter,
                  sql_current_month_t_e_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_issue(sql_where_filter, '_this_month')
            else
              logger.debug " =>prof           join_max_time_entry_by_issue          NOT needed" if debug == '2'
            end

            #-------------
            # 2.3) By User, Filter on visible time entries
            if join_max_t_e_by_user_this_month
              logger.debug " =>prof           +left_join_max_time_entry_id_by_user(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # Access to time entries check
                  sql_visible_issues_filter,
                  sql_current_month_t_e_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_user(sql_where_filter, '_this_month')
            else
              logger.debug " =>prof           join_max_time_entry_by_user           NOT needed" if debug == '2'
            end
          end


          ####
          # 3) join max t.e. by issue / user PREVIOUS MONTH
          if (
            join_max_t_e_by_issue_and_user_previous_month ||
            join_max_t_e_by_issue_previous_month ||
            join_max_t_e_by_user_previous_month
          )
            #-------------------------------------------
            # 3.0) Filter time entries on previous month
            date_filter = Date.today.prev_month
            sql_current_month_t_e_filter = "tyear = #{date_filter.year} AND tmonth = #{date_filter.month}"

            #-----------------------
            # 3.1) By Issue and User, Filter on visible time entries
            if join_max_t_e_by_issue_and_user_previous_month
              logger.debug " =>prof           +left_join_max_time_entry_id_by_issue_and_user(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # Access to time entries check
                  sql_visible_issues_filter,
                  sql_current_month_t_e_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_issue_and_user(sql_where_filter, '_previous_month')
            else
              logger.debug " =>prof           join_max_time_entry_by_issue_and_user NOT needed" if debug == '2'
            end


            #--------------
            # 3.2) By Issue, Filter on visible time entries
            if join_max_t_e_by_issue_previous_month
              logger.debug " =>prof           +left_join_max_time_entry_id_by_issue(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # Access to time entries check
                  sql_visible_issues_filter,
                  sql_current_month_t_e_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_issue(sql_where_filter, '_previous_month')
            else
              logger.debug " =>prof           join_max_time_entry_by_issue          NOT needed" if debug == '2'
            end

            #-------------
            # 3.3) By User, Filter on visible time entries
            if join_max_t_e_by_user_previous_month
              logger.debug " =>prof           +left_join_max_time_entry_id_by_user(...)" if debug

              sql_where_filter = self.class.sql_where_w_optional_conditions(
                  false, # where_prefix
                  # Access to time entries check
                  sql_visible_issues_filter,
                  sql_current_month_t_e_filter
                ) +
                ' '
              if debug == '2'
                logger.debug " =>prof           sql_where_filter='#{SmileTools.remove_sql_in_values(sql_where_filter)}'"
              elsif debug == '3'
                logger.debug " =>prof           sql_where_filter='#{sql_where_filter}'"
              end

              # No postfix, default select name
              joins << self.class.left_join_max_time_entry_id_by_user(sql_where_filter, '_previous_month')
            else
              logger.debug " =>prof           join_max_time_entry_by_user           NOT needed" if debug == '2'
            end
          end

          joins
        end

        # 6/ EXTENDED, RM 4.0.0 OK
        # Extends IssueQuery.joins_for_order_statement to add joins
        # Smile specific : + param debug
        def joins_for_order_statement(order_options)
          sql_joins = super(order_options)

          debug = nil
          if self.respond_to?('debug')
            debug = self.debug
          end

          if debug
            logger.debug " =>prof"
            logger.debug "\\=>prof       joins_for_order_statement ==> joins_additionnal"
            logger.debug " =>prof         order_options=#{order_options}" if debug == '2'
          end
          more_joins = joins_additionnal(order_options)

          if sql_joins.present?
            order_joins = more_joins.any? ? sql_joins + ' ' + more_joins.join(' ') : sql_joins
          else
            order_joins = more_joins.any? ? more_joins.join(' ') : nil
          end

          if debug
            logger.debug "/=>prof       joins_for_order_statement"
            logger.debug " =>prof"
          end

          order_joins
        end


        # 10/ new method, RM 4.0.0 Plugin OK
        # Smile specific #358513: Rapport temps passé : filtre Demande Créée (date)
        def sql_for_issue_created_on_field(field, operator, value)
          sql_for_field(field, operator, value, Issue.table_name, 'created_on')
        end

        # 11/ new method, RM 2.3.2 OK
        # Smile specific #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
        def sql_for_tracker_field(field, operator, value)
          sql_for_field(field, operator, value, Issue.table_name, 'tracker_id')
        end

        # 12/ new method, RM 2.3.2 OK
        # Smile specific #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
        def sql_for_subject_field(field, operator, value)
          sql_for_field(field, operator, value, Issue.table_name, 'subject')
        end

        # 13/ new method, RM 2.3.2 OK
        # Smile specific #248383 Rapport: filtre sur version et catégorie
        def sql_for_fixed_version_id_field(field, operator, value)
          sql_for_field(field, operator, value, Issue.table_name, 'fixed_version_id')
        end

        # 14/ new method, RM 2.3.2 OK
        # Smile specific #248383 Rapport: filtre sur version et catégorie
        def sql_for_issue_category_id_field(field, operator, value)
          sql_for_field(field, operator, value, Issue.table_name, 'category_id')
        end

        # 15/ new method, RM 2.6 OK
        # Smile specific #423277 Rapport : Filtre sur tâche parente et racine
        def sql_for_root_id_field(field, operator, value)
          sql_for_field(field, operator, value, Issue.table_name, 'root_id')
        end

        # 16/ new method, RM 2.6 OK
        # Smile specific #423277 Rapport : Filtre sur tâche parente et racine
        def sql_for_parent_id_field(field, operator, value)
          sql_for_field(field, operator, value, Issue.table_name, 'parent_id')
        end

        # 17/ new method, RM 2.6 OK
        # Smile specific #473776 Spent Time Report : Filter on Assignee's group
        # COPIED from IssueQuery
        def sql_for_member_of_group_field(field, operator, value)
          if operator == '*' # Any group
            groups = Group.givable
            operator = '=' # Override the operator since we want to find by assigned_to
          elsif operator == "!*"
            groups = Group.givable
            operator = '!' # Override the operator since we want to find by assigned_to
          else
            groups = Group.where(:id => value).to_a
          end
          groups ||= []

          members_of_groups = groups.inject([]) {|user_ids, group|
            user_ids + group.user_ids + [group.id]
          }.uniq.compact.sort.collect(&:to_s)

          '(' + sql_for_field("assigned_to_id", operator, members_of_groups, Issue.table_name, "assigned_to_id", false) + ')'
        end

        # 18/ new method, RM 4.0.0 OK
        # Smile specific #831010: Time Report Query : new time entry user filter, me
        def sql_for_user_id_me_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "(CASE WHEN (#{TimeEntry.table_name}.user_id = #{User.current.id}) THEN 'me' ELSE 'not_me' END)")
        end

        # 19/ new method, RM 4.0.0 OK
        # Smile specific #831010: Time Report Query : new time entry user filter, me
        def sql_for_author_id_me_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "(CASE WHEN (#{TimeEntry.table_name}.author_id = #{User.current.id}) THEN 'me' ELSE 'not_me' END)")
        end

        # 30/ new method, RM 4.0.0 OK
        def sql_for_is_last_time_entry_for_issue_and_user_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "(#{TimeEntry.table_name}.id = max_time_entry_id_by_issue_and_user.max_id)")
        end

        # 31/ new method, RM 4.0.0 OK
        def sql_for_is_last_time_entry_for_issue_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "(#{TimeEntry.table_name}.id = max_time_entry_id_by_issue.max_id)")
        end

        # 32/ new method, RM 4.0.0 OK
        def sql_for_is_last_time_entry_for_user_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "(#{TimeEntry.table_name}.id = max_time_entry_id_by_user.max_id)")
        end

        # 33/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_issue_and_user_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_issue_and_user.sum_hours_by_issue_and_user")
        end

        # 34/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_issue_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_issue.sum_hours_by_issue")
        end

        # 35/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_user_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_user.sum_hours_by_user")
        end

        # 36/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_issue_and_user_this_month_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_issue_and_user_this_month.sum_hours_by_issue_and_user")
        end

        # 37/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_issue_this_month_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_issue_this_month.sum_hours_by_issue")
        end

        # 38/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_user_this_month_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_user_this_month.sum_hours_by_user")
        end

        # 39/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_issue_and_user_previous_month_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_issue_and_user_previous_month.sum_hours_by_issue_and_user")
        end

        # 40/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_issue_previous_month_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_issue_previous_month.sum_hours_by_issue")
        end

        # 41/ new method, RM 4.0.0 OK
        def sql_for_spent_hours_for_user_previous_month_field(field, operator, value)
          sql_for_field(field, operator, value, nil, "max_time_entry_id_by_user_previous_month.sum_hours_by_user")
        end


        ###############################
        # Filters on Is last time entry
        # 40/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_issue_and_user_needed_for_filters?
          filters.include?('is_last_time_entry_for_issue_and_user') ||
            or_filters.include?('is_last_time_entry_for_issue_and_user') ||
          filters.include?('spent_hours_for_issue_and_user') ||
            or_filters.include?('spent_hours_for_issue_and_user')
        end

        # 41/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_issue_needed_for_filters?
          filters.include?('is_last_time_entry_for_issue') ||
            or_filters.include?('is_last_time_entry_for_issue') ||
          filters.include?('spent_hours_for_issue') ||
            or_filters.include?('spent_hours_for_issue')
        end

        # 42/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_user_needed_for_filters?
          filters.include?('is_last_time_entry_for_user') ||
            or_filters.include?('is_last_time_entry_for_user') ||
          filters.include?('spent_hours_for_user') ||
            or_filters.include?('spent_hours_for_user')
        end

        ########################
        # Filters on Spent Hours
        # 53/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_issue_and_user_this_month_needed_for_filters?
          filters.include?('spent_hours_for_issue_and_user_this_month') ||
            or_filters.include?('spent_hours_for_issue_and_user_this_month')
        end

        # 54/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_issue_this_month_needed_for_filters?
          filters.include?('spent_hours_for_issue_this_month') ||
            or_filters.include?('spent_hours_for_issue_this_month')
        end

        # 55/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_user_this_month_needed_for_filters?
          filters.include?('spent_hours_for_user_this_month') ||
            or_filters.include?('spent_hours_for_user_this_month')
        end

        # 56/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_issue_and_user_previous_month_needed_for_filters?
          filters.include?('spent_hours_for_issue_and_user_previous_month') ||
            or_filters.include?('spent_hours_for_issue_and_user_previous_month')
        end

        # 57/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_issue_previous_month_needed_for_filters?
          filters.include?('spent_hours_for_issue_previous_month') ||
            or_filters.include?('spent_hours_for_issue_previous_month')
        end

        # 58/ new method, RM 4.0.0 OK
        def join_max_time_entry_id_by_user_previous_month_needed_for_filters?
          filters.include?('spent_hours_for_user_previous_month') ||
            or_filters.include?('spent_hours_for_user_previous_month')
        end

        # 60/ new method, RM 4.0.0 OK
        # Returns sum of all the spent hours for issue
        def total_for_spent_hours_for_issue(scope)
          debug = nil
          if self.respond_to?('debug')
            debug = self.debug
          end

          unless join_max_time_entry_id_by_issue_needed_for_filters?
            time_entries_issue_ids_sql = scope.where.not(:issue_id => nil).pluck(:issue_id).uniq.join(', ')

            sql_time_entries_filter = " AND #{self.class.sql_in_values_or_false_if_empty(time_entries_issue_ids_sql, 'issue_id', false)} "
            scope = scope.joins(
              self.class.left_join_max_time_entry_id_by_issue(sql_time_entries_filter)
            )

            SmileTools.debug_scope(scope, 'prof', 'total_for_spent_hours_for_issue') if debug == '2'
          end

          sums = scope.sum('max_time_entry_id_by_issue.sum_hours_by_issue')
          logger.debug "==>prof       total_for_spent_hours_for_issue sums=#{sums}" if debug == '2'

          map_total(sums) {|t| t.to_f.round(2)}
        end

        # 61/ new method, RM 4.0.0 OK
        # Returns sum of all the spent hours for issue and user
        def total_for_spent_hours_for_issue_and_user(scope)
          unless join_max_time_entry_id_by_issue_and_user_needed_for_filters?
            time_entries_ids_sql = scope.where.not(:issue_id => nil).pluck(:issue_id).join(', ')

            sql_time_entries_filter = " AND #{self.class.sql_in_values_or_false_if_empty(time_entries_ids_sql, 'issue_id', false)} "
            scope = scope.joins(
              self.class.left_join_max_time_entry_id_by_issue_and_user(sql_time_entries_filter)
            )
          end

          map_total(scope.sum('max_time_entry_id_by_issue_and_user.sum_hours_by_issue_and_user')) {|t| t.to_f.round(2)}
        end

        # 62/ new method, RM 4.0.0 OK
        # Returns sum of all the spent hours for user
        def total_for_spent_hours_for_user(scope)
          unless join_max_time_entry_id_by_user_needed_for_filters?
            time_entries_user_ids_sql = scope.where.not(:user_id => nil).pluck(:user_id).uniq.join(', ')

            sql_time_entries_filter = " AND #{self.class.sql_in_values_or_false_if_empty(time_entries_user_ids_sql, 'user_id', false)} "
            scope = scope.joins(
              self.class.left_join_max_time_entry_id_by_user(sql_time_entries_filter)
            )
          end

          map_total(scope.sum('max_time_entry_id_by_user.sum_hours_by_user')) {|t| t.to_f.round(2)}
        end

        # 63/ new method, RM 4.0.0 OK
        # Returns sum of all the billable hours for issue
        def total_for_billable_hours_for_issue(scope)
          cf = TimeEntry.billable_custom_field
          scope_issue_ids = scope.where.not(:issue_id => nil).pluck(:issue_id).uniq
          scope_for_issues = TimeEntry.where(:issue_id => scope_issue_ids)
          if scope.group_values.any?
            scope_for_issues = scope_for_issues.group(scope.group_values)
          end
          if scope.joins_values.any?
            scope_for_issues = scope_for_issues.joins(scope.joins_values)
          end
          total = cf.format.total_for_scope(cf, scope_for_issues)
          total = map_total(total) {|t| cf.format.cast_total_value(cf, t)}
        end

        # 64/ new method, RM 4.0.0 OK
        # Returns sum of all the billable hours for issue and user
        def total_for_billable_hours_for_issue_and_user(scope)
          cf = TimeEntry.billable_custom_field
          scope_issue_ids = scope.where.not(:issue_id => nil).pluck(:issue_id).uniq
          scope_user_ids = scope.where.not(:user_id => nil).pluck(:user_id).uniq
          scope_for_issues_and_users = TimeEntry.where(:issue_id => scope_issue_ids).where(:user_id => scope_user_ids)
          if scope.group_values.any?
            scope_for_issues_and_users = scope_for_issues_and_users.group(scope.group_values)
          end
          if scope.joins_values.any?
            scope_for_issues_and_users = scope_for_issues_and_users.joins(scope.joins_values)
          end
          total = cf.format.total_for_scope(cf, scope_for_issues_and_users)
          total = map_total(total) {|t| cf.format.cast_total_value(cf, t)}
        end

        # 65/ new method, RM 4.0.0 OK
        # Returns sum of all the billable hours for user
        def total_for_billable_hours_for_user(scope)
          cf = TimeEntry.billable_custom_field
          scope_user_ids = scope.where.not(:user_id => nil).pluck(:user_id).uniq
          scope_for_users = TimeEntry.where(:user_id => scope_user_ids)
          if scope.group_values.any?
            scope_for_users = scope_for_users.group(scope.group_values)
          end
          if scope.joins_values.any?
            scope_for_users = scope_for_users.joins(scope.joins_values)
          end
          total = cf.format.total_for_scope(cf, scope_for_users)
          total = map_total(total) {|t| cf.format.cast_total_value(cf, t)}
        end

        # 66/ new method, RM 4.0.0 OK
        # Returns sum of all the deviation hours for issue
        def total_for_deviation_hours_for_issue(scope)
          cf = TimeEntry.deviation_custom_field
          scope_issue_ids = scope.where.not(:issue_id => nil).pluck(:issue_id).uniq
          scope_for_issues = TimeEntry.where(:issue_id => scope_issue_ids)
          if scope.group_values.any?
            scope_for_issues = scope_for_issues.group(scope.group_values)
          end
          if scope.joins_values.any?
            scope_for_issues = scope_for_issues.joins(scope.joins_values)
          end
          total = cf.format.total_for_scope(cf, scope_for_issues)
          total = map_total(total) {|t| cf.format.cast_total_value(cf, t)}
        end

        # 67/ new method, RM 4.0.0 OK
        # Returns sum of all the deviation hours for issue and user
        def total_for_deviation_hours_for_issue_and_user(scope)
          cf = TimeEntry.deviation_custom_field
          scope_issue_ids = scope.where.not(:issue_id => nil).pluck(:issue_id).uniq
          scope_user_ids = scope.where.not(:user_id => nil).pluck(:user_id).uniq
          scope_for_issues_and_users = TimeEntry.where(:issue_id => scope_issue_ids).where(:user_id => scope_user_ids)
          if scope.group_values.any?
            scope_for_issues_and_users = scope_for_issues_and_users.group(scope.group_values)
          end
          if scope.joins_values.any?
            scope_for_issues_and_users = scope_for_issues_and_users.joins(scope.joins_values)
          end
          total = cf.format.total_for_scope(cf, scope_for_issues_and_users)
          total = map_total(total) {|t| cf.format.cast_total_value(cf, t)}
        end

        # 68/ new method, RM 4.0.0 OK
        # Returns sum of all the deviation hours for user
        def total_for_deviation_hours_for_user(scope)
          cf = TimeEntry.deviation_custom_field
          scope_user_ids = scope.where.not(:user_id => nil).pluck(:user_id).uniq
          scope_for_users = TimeEntry.where(:user_id => scope_user_ids)
          if scope.group_values.any?
            scope_for_users = scope_for_users.group(scope.group_values)
          end
          if scope.joins_values.any?
            scope_for_users = scope_for_users.joins(scope.joins_values)
          end
          total = cf.format.total_for_scope(cf, scope_for_users)
          total = map_total(total) {|t| cf.format.cast_total_value(cf, t)}
        end


        module ClassMethods
          # 1/ New method RM 4.0.3  Plugin OK
          def sql_max_time_entry_id_by_issue_and_user(postfix='')
            '('+
              'SELECT issue_id, user_id, MAX(id) AS max_id, SUM(hours) AS sum_hours_by_issue_and_user ' +
              'FROM time_entries ' +
              'WHERE ' +
                'issue_id IS NOT NULL ' +
                #        ************************************************
                '%s' + # OPTIONAL FILTER to reduce time entries processed
              'GROUP BY issue_id, user_id ' +
              'ORDER BY issue_id ASC, user_id ASC, spent_on ASC, id ASC ' +
            " ) AS max_time_entry_id_by_issue_and_user#{postfix}"
          end

          # 2/ new method, RM 4.0.3 OK
          def sql_max_time_entry_id_by_issue(postfix='')
            '('+
              'SELECT issue_id, MAX(id) AS max_id, SUM(hours) AS sum_hours_by_issue ' +
              'FROM time_entries ' +
              'WHERE ' +
                'issue_id IS NOT NULL ' +
                #        ************************************************
                '%s' + # OPTIONAL FILTER to reduce time entries processed
              'GROUP BY issue_id ' +
              'ORDER BY issue_id ASC, spent_on ASC, id ASC ' +
            " ) AS max_time_entry_id_by_issue#{postfix}"
          end

          # 3/ new method, RM 4.0.3 OK
          def sql_max_time_entry_id_by_user(postfix='')
            '('+
              'SELECT user_id, MAX(id) AS max_id, SUM(hours) AS sum_hours_by_user ' +
              'FROM time_entries ' +
              'WHERE ' +
                'user_id IS NOT NULL ' + # never happen, just to have a where condition
                #        ************************************************
                '%s' + # OPTIONAL FILTER to reduce time entries processed
              'GROUP BY user_id ' +
              'ORDER BY user_id ASC, spent_on ASC, id ASC ' +
            " ) AS max_time_entry_id_by_user#{postfix}"
          end

          # 4/ new method, RM 4.0.0 OK
          def left_join_max_time_entry_id_by_issue_and_user(
            sql_issues_select='',
            postfix=''
          )
            sql_max_time_entry_id_by_issue_and_user_to_filter = sql_max_time_entry_id_by_issue_and_user(postfix)

            'LEFT OUTER JOIN ' +
              (sql_max_time_entry_id_by_issue_and_user_to_filter % sql_issues_select) +
              ' ON (' +
                "max_time_entry_id_by_issue_and_user#{postfix}.issue_id = #{TimeEntry.table_name}.issue_id AND " +
                "max_time_entry_id_by_issue_and_user#{postfix}.user_id = #{TimeEntry.table_name}.user_id" +
              ')'
          end

          # 5/ new method, RM 4.0.0 OK
          def left_join_max_time_entry_id_by_issue(
            sql_issues_select='',
            postfix=''
          )
            sql_max_time_entry_id_by_issue_to_filter = sql_max_time_entry_id_by_issue(postfix)

            'LEFT OUTER JOIN ' +
              (sql_max_time_entry_id_by_issue_to_filter % sql_issues_select) +
              ' ON (' +
                "max_time_entry_id_by_issue#{postfix}.issue_id = #{TimeEntry.table_name}.issue_id" +
              ')'
          end

          # 6/ new method, RM 4.0.0 OK
          def left_join_max_time_entry_id_by_user(
            sql_issues_select='',
            postfix=''
          )
            sql_max_time_entry_id_by_user_to_filter = sql_max_time_entry_id_by_user(postfix)

            'LEFT OUTER JOIN ' +
              (sql_max_time_entry_id_by_user_to_filter % sql_issues_select) +
              ' ON (' +
                "max_time_entry_id_by_user#{postfix}.user_id = #{TimeEntry.table_name}.user_id" +
              ')'
          end

          # 10/ new method RM 4.0.3 OK
          # Smile specific #271407 Time Entries : filter by BU
          # Smile specific #269602 Rapport de temps : critère BU
          def joins_for_bu_project_id
            return @@sql_for_bu_project_id if defined?(@@sql_for_bu_project_id)

            @@sql_for_bu_project_id =
              'LEFT OUTER JOIN (' +
                 'SELECT p.id, cv_is_bu.customized_id ' +
                "FROM #{Project.table_name} AS p " +
                  "LEFT OUTER JOIN #{Project.table_name} AS parent_projects " +
                    "ON (parent_projects.lft <= p.lft AND parent_projects.rgt >= p.rgt) " +
                  "LEFT OUTER JOIN #{CustomValue.table_name} AS cv_is_bu " +
                    "ON (cv_is_bu.custom_field_id = #{Project.is_bu_project_cf_id} AND cv_is_bu.customized_id = parent_projects.id) " +
                'WHERE cv_is_bu.customized_id IS NOT NULL AND ' +
                  'cv_is_bu.value = 1 '+
                'ORDER BY cv_is_bu.customized_id ASC' +
              ') AS bu_project_id ON (bu_project_id.id = projects.id)'
          end
        end # module ClassMethods
      end # module ExtendedQueries
    end # module TimeEntryQueryOverride
  end # module Models
end # module Smile
