# Smile - add methods to the IssueQuery model

# TESTED
#
# #########################
# 1/ module ExtendedQueries
# - #134828 (Array, IssueRelations, Watchers)
#   - columns
#     - watchers
#
# - #77476 Demandes : colonne Tâche racine
#   2012
#   - filter on
#     - root_id
#
# - #147568 Filter on parent task
#   2013
#   - filter on
#     - parent_id
#     - children_count
#
# - #256456 Sauvegarder la case à cocher "Include sub-tasks time"
#   2014
#
# - #412709 Demandes : Filtre + Colonne "Projet de la demande parente"
#   2015-10

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module IssueQueryOverride
      ####################
      # 1/ ExtendedQueries
      module ExtendedQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1) Instance methods
          extended_queries_instance_methods = [
            :initialize_available_filters,          # 1/  REWRITTEN  TESTED  RM V4.0.0 OK
            :available_filters_hook,                # 2/  new        TESTED  RM V4.0.0 OK

            :build_from_params,                     # 15/ OVERRIDEN  TESTED  RM V4.0.0 OK
            :build_from_advanced_params,            # 16/ new        TESTED  RM V4.0.0 OK

            :sql_for_parent_project_id_field,       # 43/ new        TESTED  RM V4.0.0 OK
          ]

          trace_prefix = "#{' ' * (base.name.length + 22)}  --->  "
          last_postfix = '< (SM::MO::IssueQueryOverride::ExtendedQueries)'

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
            trace_first_prefix = "#{base.name} MISS       instance_methods  "
          else
            trace_first_prefix = "#{base.name}            instance_methods  "
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

          ######################
          # 2) New Query Columns
          # Smile specific : adding here new NON OPTIONNAL columns
          # Smile comment : access to class object directly : @@available_columns

          # Smile specific #355551 Requête perso demandes : filtre projet mis-à-jour
          # Smile specific #469832 Demandes : nouvelles colonnes Sujet Tâche Parente / Racine
          # Smile specific #393391 Requête perso Demandes : colonne BU
          new_query_columns_names = [
            :root, # Smile specific #77476 Demandes : colonne Tâche racine
            :parent_project, # Smile specific #412709 Demandes : Filtre + Colonne "Projet de la demande parente"
            :watchers,
            :parent_subject,
            :root_subject,
            :project_updated_on,
            :bu_project
          ]

          #---------------
          # Smile specific #77476 Demandes : colonne Tâche racine
          # Smile comment : 1/ ROOT
          index = base.available_columns.find_index {|column| column.name == :parent}
          base.available_columns.insert (index + 1), QueryColumn.new(
            :root,
            :sortable => "#{Issue.table_name}.root_id",
            :default_order => 'desc',
            :caption => lambda {::I18n.t(:field_issue_root_id)},
            :groupable => "#{Issue.table_name}.root_id" #'root_id' # 'root_id', possible but NOT used by upstream, != of QueryColumn name
          )
          # END -- Smile specific #77476 Demandes : colonne Tâche racine
          #----------------------

          # Smile specific #830767 Issue Query : Sort / Group by parent / root position
          if (
            # Avoid an error when creating DB
            ActiveRecord::Base.connection.data_source_exists?('issues') &&
            Issue.column_names.include?('position')
          )
            base.available_columns.insert (index + 1), QueryColumn.new(
              :position,
              :sortable => "#{Issue.table_name}.position",
              :default_order => 'desc',
              :caption => lambda {::I18n.t(:field_position)},
              :groupable => true
            )
          end

          #---------------
          # Smile specific #412709 Demandes : Filtre + Colonne "Projet de la demande parente"
          # Smile comment : 2/ PARENT PROJECT
          index = base.available_columns.find_index {|column| column.name == :root}
          base.available_columns.insert (index + 1), QueryColumn.new(:parent_project,
            :sortable => "(SELECT project_id FROM issues AS parents WHERE parents.id = #{Issue.table_name}.parent_id)",
            :groupable => "(SELECT project_id FROM issues AS parents WHERE parents.id = #{Issue.table_name}.parent_id)",
            :default_order => 'desc',
            :caption => lambda {::I18n.t(:field_parent_project)}
          )
          # END -- Smile specific #412709 Demandes : Filtre + Colonne "Projet de la demande parente"
          #----------------------

          ################
          # Smile specific #393391 Requête perso Demandes : colonne BU
          # Smile comment : 3/ BU
          index = base.available_columns.find_index {|column| column.name == :parent_project}
          base.available_columns.insert (index + 1), QueryColumn.new(:bu_project,
            :caption => lambda {I18n.t(:label_bu)}
          )
          # END -- Smile specific #393391 Requête perso Demandes : colonne BU
          #######################

          # Smile comment : 4/ WATCHERS
          index = base.available_columns.find_index {|column| column.name == :bu_project}
          base.available_columns.insert (index + 1), QueryColumn.new(:watchers)

          ################
          # Smile specific #469832 Demandes : nouvelles colonnes Sujet Tâche Parente / Racine
          # Smile comment : 5/ PARENT / ROOT SUBJECT
          # Smile specific : get subject column index
          index = base.available_columns.find_index {|column| column.name == :subject}

          # Smile specific #830767 Issue Query : Sort / Group by parent / root position
          if (
            # Avoid an error when creating DB
            ActiveRecord::Base.connection.data_source_exists?('issues') &&
            Issue.column_names.include?('position')
          )
            base.available_columns.insert (index + 1), QueryColumn.new(
                :parent_position,
                :sortable => "(SELECT position FROM issues AS issue_parents WHERE issue_parents.id = #{Issue.table_name}.parent_id)",
                :groupable => "(SELECT position FROM issues AS issue_parents WHERE issue_parents.id = #{Issue.table_name}.parent_id)",
                :default_order => 'asc',
                :caption => lambda {"#{I18n.t(:field_issue_parent_id)} -- (#{I18n.t(:field_position)})"}
              )
          end

          base.available_columns.insert (index + 1), QueryColumn.new(
              :parent_subject,
              :sortable => ["#{Issue.table_name}.root_id", "#{Issue.table_name}.lft ASC"],
              :default_order => 'desc',
              :caption => lambda {"#{I18n.t(:field_parent_issue)} -- (#{I18n.t(:field_subject)})" }
            )

          if (
            # Avoid an error when creating DB
            ActiveRecord::Base.connection.data_source_exists?('issues') &&
            Issue.column_names.include?('position')
          )
            base.available_columns.insert (index + 1), QueryColumn.new(
                :root_position,
                :sortable => "(SELECT position FROM issues AS issue_roots WHERE issue_roots.id = #{Issue.table_name}.root_id)",
                :groupable => "(SELECT position FROM issues AS issue_roots WHERE issue_roots.id = #{Issue.table_name}.root_id)",
                :default_order => 'asc',
                :caption => lambda {"#{I18n.t(:field_issue_root_id)} -- (#{I18n.t(:field_position)})"}
              )
          end

          base.available_columns.insert (index + 1), QueryColumn.new(
              :root_subject,
              :sortable => "#{Issue.table_name}.root_id",
              :default_order => 'desc',
              :caption => lambda {"#{I18n.t(:field_issue_root_id)} -- (#{I18n.t(:field_subject)})"}
            )
          # END -- Smile specific #469832 Demandes : nouvelles colonnes Sujet Tâche Parente / Racine
          #######################


          ################
          # Smile specific #355551 Requête perso demandes : filtre projet mis-à-jour
          # Smile specific : 6/ PROJECT UPDATED ON
          # Smile specific : get updated_on column index
          index = base.available_columns.find_index {|column| column.name == :updated_on}
          # Smile specific : insert AFTER updated_on
          base.available_columns.insert (index + 1), QueryColumn.new(:project_updated_on,
            :sortable => 'projects_updated_on_from_issues_by_project_id.project_updated_on',
            :default_order => 'desc',
            :caption => lambda {"#{I18n.t(:label_project)} #{I18n.t(:field_updated_on)}"}
          )
          # END -- Smile specific #355551 Requête perso demandes : filtre projet mis-à-jour
          #######################


          current_query_columns_names = base.available_columns.select{|ac| new_query_columns_names.include?(ac.name)}.collect(&:name)

          missing_query_columns_names = new_query_columns_names.select{|ac|
              ! current_query_columns_names.include?(ac)
            }

          if missing_query_columns_names.any?
            trace_first_prefix = "#{base.name} MISS      available_columns  "
          else
            trace_first_prefix = "#{base.name}           available_columns  "
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
          # END -- Smile specific : adding here new NON OPTIONNAL columns
          #######################


          ########################
          # 3/ New safe_attributes
          base.instance_eval do
            ################
            # Smile specific #340206 Filtre additifs
            include Redmine::SafeAttributes

            safe_attributes 'or_filters'
            serialize :or_filters
            # END -- Smile specific #340206 Filtre additifs
            #######################
          end

          trace_first_prefix = "#{base.name}             safe_attributes  "

          SmileTools::trace_by_line(
            (
              ['+ or_filters']
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_xtended_queries
          )
        end

        # 1/ REWRITTEN, RM 4.0.0 OK
        # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
        # Smile specific #147568 Filter on parent task
        # Smile specific #393868 Filtres requête perso. : tronquer à 60 cars titre demande
        # Smile specific #354800 Requête perso demandes : filtre projet mis-à-jour
        # Smile specific #412709 Demandes : Filtre + Colonne "Projet de la demande parente"
        def initialize_available_filters
          add_available_filter "status_id",
            :type => :list_status, :values => lambda { issue_statuses_values }

          add_available_filter("project_id",
            :type => :list, :values => lambda { project_values }
          ) if project.nil?

          add_available_filter "tracker_id",
            :type => :list, :values => trackers.collect{|s| [s.name, s.id.to_s] }

          add_available_filter "priority_id",
            :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }

          add_available_filter("author_id",
            :type => :list, :values => lambda { author_values }
          )

          add_available_filter("assigned_to_id",
            :type => :list_optional, :values => lambda { assigned_to_values }
          )

          ################
          # Smile specific #434443 Demandes : Filtre "Groupe de l'assigné à"
          # Smile specific : order by group name
          add_available_filter("member_of_group",
            :type => :list_optional, :values => lambda { Group.givable.visible.order('lastname').collect {|g| [g.name, g.id.to_s] } }
          )

          add_available_filter("assigned_to_role",
            :type => :list_optional, :values => lambda { Role.givable.collect {|r| [r.name, r.id.to_s] } }
          )

          add_available_filter "fixed_version_id",
            :type => :list_optional, :values => lambda { fixed_version_values }

          add_available_filter "fixed_version.due_date",
            :type => :date,
            :name => l(:label_attribute_of_fixed_version, :name => l(:field_effective_date))

          add_available_filter "fixed_version.status",
            :type => :list,
            :name => l(:label_attribute_of_fixed_version, :name => l(:field_status)),
            :values => Version::VERSION_STATUSES.map{|s| [l("version_status_#{s}"), s] }

          add_available_filter "category_id",
            :type => :list_optional,
            :values => lambda { project.issue_categories.collect{|s| [s.name, s.id.to_s] } } if project

          add_available_filter "subject", :type => :text
          add_available_filter "description", :type => :text
          add_available_filter "created_on", :type => :date_past
          add_available_filter "updated_on", :type => :date_past

          ################
          # Smile specific #354800 Requête perso demandes : filtre projet mis-à-jour
          # Smile comment : No way to filter projects of sub-request for project_updated_on, if no project
          if project
            add_available_filter 'project_updated_on',
              :type => :date_past,
              :name => "#{l(:label_project)} #{l(:field_updated_on)}"
          end
          # END -- Smile specific #354800 Requête perso demandes : filtre projet mis-à-jour
          #######################

          add_available_filter "closed_on", :type => :date_past
          add_available_filter "start_date", :type => :date
          add_available_filter "due_date", :type => :date

          ################
          # Smile specific #786266 V4.0.0 : Issues query filters, bar fields, with subtasks indication
          if respond_to?('with_children')
            label_with_children = ( with_children ? " (#{I18n.t(:label_with_children)})" : '' )
          else
            label_with_children = ''
          end


          # Smile specific : + name
          add_available_filter "estimated_hours", :type => :float, :name => "#{I18n.t(:field_estimated_hours)}#{label_with_children}"

          ################
          # Smile specific : new hook
          available_filters_hook

          add_available_filter "done_ratio", :type => :integer, :name => "#{I18n.t(:field_done_ratio)}#{label_with_children}"

          if User.current.allowed_to?(:set_issues_private, nil, :global => true) ||
            User.current.allowed_to?(:set_own_issues_private, nil, :global => true)
            add_available_filter "is_private",
              :type => :list,
              :values => [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]]
          end

          add_available_filter "attachment",
            :type => :text, :name => l(:label_attachment)

          if User.current.logged?
            add_available_filter "watcher_id",
              :type => :list, :values => lambda { watcher_values }
          end

          add_available_filter("updated_by",
            :type => :list, :values => lambda { author_values }
          )

          add_available_filter("last_updated_by",
            :type => :list, :values => lambda { author_values }
          )

          #******************
          # Sub-tasks filters
          #******************
          if project && !project.leaf?
            ################
            # Smile specific #768560: V4.0.0 : Time entries list : access to hidden BAR values
            # Smile specific : with parent project
            add_available_filter "subproject_id",
              :type => :list_subprojects,
              :values => lambda { subproject_values(true) }
          end

          ################
          # Smile specific #412709 Demandes : Filtre + Colonne "Projet de la demande parente"
          if project
            add_available_filter 'parent_project_id',
              :name => l('field_parent_project'),
              :type => :list_optional,
              :values => lambda { project_and_children.collect{|c| [c.name, c.id.to_s]} }
          end
          # END -- Smile specific #412709 Demandes : Filtre + Colonne "Projet de la demande parente"
          #######################

          ################
          # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
          if self.respond_to?('advanced_filters') && advanced_filters
            if project
              # Smile specific #147568 Filter on parent task
              add_available_filter 'root_id',
                :name => l('field_issue_root_id'),
                :type => :list_optional,
                :values => lambda {
                  calc_project_and_children_issues
                  @children_root_issues_id_and_label
                }

              # Smile specific #147568 Filter on parent task
              add_available_filter 'parent_id',
                :name => l('field_issue_parent_id'),
                :type => :list_optional,
                :values => lambda {
                  calc_project_and_children_issues
                  @children_parent_issues_id_and_label
                }

              add_available_filter 'id',
                :name => l('field_issue'),
                :type => :list_optional,
                :values => lambda {
                  calc_project_and_children_issues
                  @children_issues_id_and_label
                }
            end

            # Smile specific #147568 Filter on parent task
            # children_count
            # Works even if NO project specified
            add_available_filter 'children_count', :type => :integer

            #--------------------------------------------------
            # Smile specific #226967 Filter 'number of parents'
            add_available_filter 'level_in_tree',
              :type => :integer
            # Smile specific #226967 Filter 'number of parents'
            #--------------------------------------------------
          end # if self.respond_to?('advanced_filters') && advanced_filters
          # END -- Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
          #######################
          #*************************
          # END -- Sub-tasks filters
          #*************************

          add_custom_fields_filters(issue_custom_fields)
          add_associations_custom_fields_filters :project, :author, :assigned_to, :fixed_version

          IssueRelation::TYPES.each do |relation_type, options|
            add_available_filter relation_type, :type => :relation, :label => options[:name], :values => lambda {all_projects_values}
          end

          ################
          # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
          # Smile specific : only if advanced filters NOT enabled
          unless self.respond_to?('advanced_filters') && advanced_filters
            add_available_filter "parent_id", :type => :tree, :label => :field_parent_issue
            add_available_filter "child_id", :type => :tree, :label => :label_subtask_plural

            add_available_filter "issue_id", :type => :integer, :label => :label_issue
          end

          Tracker.disabled_core_fields(trackers).each {|field|
            delete_available_filter field
          }
        end

        ###############
        # 2/ New method, RM 4.0.0 OK
        # Smile specific : new hook
        def available_filters_hook
          # Does nothing here
        end

        # 15/ EXTENDED, RM 4.0.0 OK
        # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
        # Smile specific #340206 Filtre additifs
        def build_from_params(params, defaults={})
          ################
          # Smile specific
          build_from_advanced_params(params)

          if Redmine::VERSION::MAJOR < 4
            super(params)
          else
            super(params, defaults)
          end

          self
        end

        # 16/ new method, RM 4.0.0 OK
        # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
        # Smile specific #227343 Demandes : Export CSV + Pdf, option conversion en jours
        # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
        # Smile specific #340206 Filtre additifs
        def build_from_advanced_params(params)
          ################
          # Smile specific
          ################
          # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
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
          # Smile specific #227343 Demandes : Export CSV + Pdf, option conversion en jours
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
        end


        # 43/ new method, RM 4.0.0 OK
        # Smile specific #412709 Demandes : Filtre + Colonne "Projet de la demande parente"
        def sql_for_parent_project_id_field(field, operator, value)
          sql_for_field(field, operator, value, '', "(SELECT project_id FROM issues AS parents WHERE parents.id = #{Issue.table_name}.parent_id)")
        end
      end # module ExtendedQueries
   end # module IssueQueryOverride
  end # module Models
end # module Smile
