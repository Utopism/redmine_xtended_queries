# Smile - add methods to the Time Entry Query model
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
    module TimeReportQueryOverride
      ####################
      # 1/ ExtendedQueries
      module ExtendedQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1) Instance methods
          extended_queries_instance_methods = [
            :results_scope,                                               #  1/ EXTENDED    TO TEST  RM V4.0.0 OK
            :build_from_params,                                           #  2/ EXTENDED    TO TEST  RM V4.0.0 OK
            :initialize_available_filters,                                #  3/ REWRITTEN   TO TEST  RM V4.0.0 OK

            :sql_for_issue_created_on_field,                              # 10/ new method  TO TEST  RM V4.0.0 OK
            :sql_for_tracker_field,                                       # 11/ new method  TO TEST  RM V4.0.0 OK
            :sql_for_subject_field,                                       # 12/ new method  TO TEST  RM V4.0.0 OK
            :sql_for_fixed_version_id_field,                              # 13/ new method  TO TEST  RM V4.0.0 OK
            :sql_for_issue_category_id_field,                             # 14/ new method  TO TEST  RM V4.0.0 OK
            :sql_for_root_id_field,                                       # 15/ new method  TO TEST  RM V4.0.0 OK
            :sql_for_parent_id_field,                                     # 16/ new method  TO TEST  RM V4.0.0 OK
            :sql_for_member_of_group_field,                               # 17/ new method  TO TEST  RM V4.0.0 OK COPIED from IssueQuery
            :sql_for_user_id_me_field,                                    # 18/ new method  TO TEST  RM V4.0.0 OK
            :sql_for_author_id_me_field,                                  # 19/ new method  TO TEST  RM V4.0.0 OK
          ]

          trace_prefix = "#{' ' * (base.name.length + 17)}  --->  "
          last_postfix = '< (SM::MO::TimeReportQueryOverride::ExtendedQueries)'

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
            trace_first_prefix = "#{base.name} MISS  instance_methods  "
          else
            trace_first_prefix = "#{base.name}       instance_methods  "
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

          trace_first_prefix = "#{base.name}        safe_attributes  "

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
          # 4) Class methods
          extended_queries_class_methods = [
            :joins_for_bu_project_id,                        # 10/ new method  TO TEST RM V4.0.0 OK
          ]

          last_postfix = '< (SM::MO::TimeReportQueryOverride::ExtendedQueries::CMeths)'

          base.singleton_class.prepend ClassMethods


          smile_class_methods = base.methods.select{|m|
              base.method(m).owner == ClassMethods
            }

          missing_class_methods = extended_queries_class_methods.select{|m|
            !smile_class_methods.include?(m)
          }

          if missing_class_methods.any?
            trace_first_prefix = "#{base.name} MISS           methods  "
          else
            trace_first_prefix = "#{base.name}                methods  "
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
          ) if project.nil?
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

          ################
          # Smile specific #994 Budget and Remaining enhancement
          # + REMAINING HOURS
          add_available_filter "remaining_hours", :type => :float if budget_and_remaining_enabled
          # END -- Smile specific #994 Budget and Remaining enhancement
          #######################

          add_custom_fields_filters(TimeEntryCustomField)
          add_associations_custom_fields_filters :project
          add_custom_fields_filters(issue_custom_fields, :issue)
          add_associations_custom_fields_filters :user
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


        module ClassMethods
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
    end # module TimeReportQueryOverride
  end # module Models
end # module Smile
