# Smile - add methods to the Query model
#
# Mainly TESTED
#
# 1/ module ExtendedQueries
# * #147568 Filter on parent task
# * #256456 Sauvegarder la case à cocher "Include sub-tasks time"
# * #354800 Requête perso Demandes / Rapport / Historiques : filtre projet mis-à-jour
# * #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
# * #763000 Totalable colums : hide checkbox if not enable on project nor sub-projects
#   DISABLED

# 2/ module ForbidPublicGlobalQueries
# * #346641 Forbid setting query public to others than me for non-admins

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module QueryOverride
      #*******************
      # 1/ ExtendedQueries
      module ExtendedQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1/ Instance methods
          enhancements_instance_methods = [
            :with_children,                        #  1/ new method  TESTED           OK
            :with_children=,                       #  2/ new method  TESTED           OK
            :group_additional_infos,               #  3/ new method  TESTED           OK
            :group_additional_infos=,              #  4/ new method  TESTED           OK
            :advanced_filters,                     #  5/ new method  TESTED           OK
            :advanced_filters=,                    #  6/ new method  TESTED           OK
            :sql_for_field,                        #  7/ REWRITTEN   TESTED  RM 4.0.0 OK
            :date_clause,                          #  8/ REWRITTEN   TESTED  RM 4.0.0 OK
            :filter_column_on_projects,            #  9/ COPIED      TESTED  RM 4.0.0 OK
            :sql_for_project_updated_on_field,     # 10/ new method  TESTED           OK
            :sql_for_bu_project_field        ,     # 11/ new method  TESTED           OK
            :sql_for_children_count_field,         # 12/ new method  TESTED           OK
            :sql_for_level_in_tree_field,          # 13/ new method  TESTED           OK
            :statement,                            # 14/ REWRITTEN   PLUGIN           OK

            :subproject_values,                    # 15/ REWRITTEN   TESTED  RM 4.0.0 OK
            :subproject_values_condition_hook,     # 16/ new method  TESTED  RM 4.0.0 OK
            :project_and_children_ids,             # 17/ new method  TESTED  RM 4.0.0 OK
            :project_and_children,                 # 18/ new method  TESTED  RM 4.0.0 OK
            :calc_project_and_children_issues,     # 19/ new method  TESTED  RM 4.0.0 OK
            :available_totalable_columns_DISABLED, # 20/ EXTENDED    TESTED  RM 4.0.0 OK
            :project_statement,                    # 21/ REWRITTEN   TESTED  RM 4.0.0 OK
            :total_for,                            # 22/ REWRITTEN   TO TEST RM 4.0.0 OK
            :total_by_group_for,                   # 23/ REWRITTEN   TO TEST RM 4.0.0 OK
            :total_with_scope,                     # 24/ REWRITTEN   TO TEST RM 4.0.0 OK
            :sql_visible_time_entries_issues_ids,  # 25/ new         TO TEST RM 4.0.0 OK

            ################
            # Smile specific #340206 Filtre additifs
            :add_or_filter,                        # 40/ new method  TESTED  RM 4.0.0 OK
            :add_or_filters,                       # 41/ new method  TESTED  RM 4.0.0 OK
            :has_or_filter?,                       # 42/ new method  TESTED  RM 4.0.0 OK
            :add_filter_error,                     # 43/ REWRITTEN   TESTED  RM 4.0.0 OK
            :or_operator_for,                      # 44/ new method  TESTED  RM 4.0.0 OK
            :or_values_for,                        # 45/ new method  TESTED  RM 4.0.0 OK
            :or_value_for,                         # 46/ new method  TESTED  RM 4.0.0 OK
            :validate_query_filters,               # 47/ EXTENDED    TESTED  RM 4.0.0 OK
            :or_filters,                           # 48/ new method  TESTED  RM 4.0.0 OK

            # Following Protected
          ]

          trace_prefix = "#{' ' * (base.name.length + 27)}  --->  "
          last_postfix = '< (SM::MO::QueryOverride::ExtendedQueries)'


          smile_instance_methods = base.public_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }
          smile_instance_methods += base.protected_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          smile_instance_methods += base.private_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = enhancements_instance_methods.select{|m|
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


          ##################
          # 3/ Class methods
          enhancements_class_methods = [
            :with_children_provided?,                         # 1/  new method  TESTED           OK
            :group_additional_infos_provided?,                # 2/  new method  TESTED           OK
            :sql_projects_updated_on_from_issues_by_project,  # 3/  new method  TESTED  RM 4.0.0 OK
            :left_join_project_updated_on_from_issues,        # 4/  new method  TESTED  RM 4.0.0 OK
            :advanced_filters_provided?,                      # 5/  new method  TESTED  RM 4.0.0 OK
            :or_filters_provided?,                            # 6/  new method  TESTED  RM 4.0.0 OK
            :sql_in_values_or_false_if_empty,                 # 7/  new method  TO TEST RM 4.0.0 OK
            :sql_where_w_optional_conditions,                 # 8/  new method  TO TEST RM 4.0.0 OK
          ]

          base.singleton_class.prepend ClassMethods

          last_postfix = '< (SM::MO::QueryOverride::ExtendedQueries::CMeths)'

          smile_class_methods = base.methods.select{|m|
              base.method(m).owner == ClassMethods
            }

          missing_class_methods = enhancements_class_methods.select{|m|
            !smile_class_methods.include?(m)
          }

          if missing_class_methods.any?
            trace_first_prefix = "#{base.name} MISS                     methods  "
          else
            trace_first_prefix = "#{base.name}                          methods  "
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


        # 1/ new method
        # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
        def with_children
          r = options[:with_children]
          r.present? && r == '1'
        end

        # 2/ new method
        # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
        def with_children=(arg)
          options[:with_children] = (arg == '1' ? '1' : nil)
        end

        # 3/ new method
        # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
        def group_additional_infos
          r = options[:group_additional_infos]
          r.present? && r == '1'
        end

        # 4/ new method
        # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
        def group_additional_infos=(arg)
          options[:group_additional_infos] = (arg == '1' ? '1' : nil)
        end

        # 5/ new method
        # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
        def advanced_filters
          r = options[:advanced_filters]
          r.present? && r == '1'
        end

        # 6/ new method
        # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
        def advanced_filters=(arg)
          options[:advanced_filters] = (arg == '1' ? '1' : nil)
        end

        # 7/ REWRITTEN PRIVATE, rewritten RM 4.0.0 OK
        # must be here in the parent Query class
        # Smile specific #147568 Filter on parent task
        # Smile specific : manage case where db_table param is not provided
        #
        # Helper method to generate the WHERE sql for a +field+, +operator+ and a +value+
        def sql_for_field(field, operator, value, db_table, db_field, is_custom_filter=false)
          sql = ''

          #---------------
          # Smile specific : manage case where db_table param is not provided
          db_table_and_field = (db_table.present? ? "#{db_table}." : '') + "#{db_field}"

          case operator
          when "="
            if value.any?
              case type_for(field)
              when :date, :date_past
                sql = date_clause(db_table, db_field, parse_date(value.first), parse_date(value.first), is_custom_filter)
              when :integer
                int_values = value.first.to_s.scan(/[+-]?\d+/).map(&:to_i).join(",")
                #---------------
                # Smile specific : manage case where db_table param is not provided
                if int_values.present?
                  if is_custom_filter
                    sql = "(#{db_table_and_field} <> '' AND CAST(CASE #{db_table_and_field} WHEN '' THEN '0' ELSE #{db_table_and_field} END AS decimal(30,3)) = #{int_values})"
                  else
                    sql = "#{db_table_and_field} IN (#{int_values})"
                  end
                else
                  sql = "1=0"
                end
              when :float
                #---------------
                # Smile specific : manage case where db_table param is not provided
                if is_custom_filter
                  sql = "(#{db_table_and_field} <> '' AND CAST(CASE #{db_table_and_field} WHEN '' THEN '0' ELSE #{db_table_and_field} END AS decimal(30,3)) BETWEEN #{value.first.to_f - 1e-5} AND #{value.first.to_f + 1e-5})"
                else
                  sql = "#{db_table_and_field} BETWEEN #{value.first.to_f - 1e-5} AND #{value.first.to_f + 1e-5}"
                end
              else
                sql = queried_class.send(:sanitize_sql_for_conditions, ["#{db_table_and_field} IN (?)", value])
              end
            else
              # IN an empty set
              sql = "1=0"
            end
          when "!"
            if value.any?
              # Smile specific : manage case where db_table param is not provided
              sql = queried_class.send(:sanitize_sql_for_conditions, ["(#{db_table_and_field} IS NULL OR #{db_table_and_field} NOT IN (?))", value])
            else
              # NOT IN an empty set
              sql = "1=1"
            end
          when "!*"
            #---------------
            # Smile specific : manage case where db_table param is not provided
            sql = "#{db_table_and_field} IS NULL"
            sql << " OR #{db_table_and_field} = ''" if (is_custom_filter || [:text, :string].include?(type_for(field)))
          when "*"
            #---------------
            # Smile specific : manage case where db_table param is not provided
            sql = "#{db_table_and_field} IS NOT NULL"
            sql << " AND #{db_table_and_field} <> ''" if is_custom_filter
          when ">="
            #---------------
            # Smile specific #147568 Filter on parent task
            # Smile specific : manage case where db_table param is not provided
            if [:date, :date_past].include?(type_for(field))
              sql = date_clause(db_table, db_field, parse_date(value.first), nil, is_custom_filter)
            else
              #---------------
              # Smile specific : manage case where db_table param is not provided
              if is_custom_filter
                sql = "(#{db_table_and_field} <> '' AND CAST(CASE #{db_table_and_field} WHEN '' THEN '0' ELSE #{db_table_and_field} END AS decimal(30,3)) >= #{value.first.to_f})"
              else
                sql = "#{db_table_and_field} >= #{value.first.to_f}"
              end
            end
          when "<="
            if [:date, :date_past].include?(type_for(field))
              sql = date_clause(db_table, db_field, nil, parse_date(value.first), is_custom_filter)
            else
              #---------------
              # Smile specific #147568 Filter on parent task
              # Smile specific, manage case where db_table param is not provided
              if is_custom_filter
                sql = "(#{db_table_and_field} <> '' AND CAST(CASE #{db_table_and_field} WHEN '' THEN '0' ELSE #{db_table_and_field} END AS decimal(30,3)) <= #{value.first.to_f})"
              else
                sql = "#{db_table_and_field} <= #{value.first.to_f}"
              end
            end
          when "><"
            if [:date, :date_past].include?(type_for(field))
              sql = date_clause(db_table, db_field, parse_date(value[0]), parse_date(value[1]), is_custom_filter)
            else
              #---------------
              # Smile specific : manage case where db_table param is not provided
              if is_custom_filter
                sql = "(#{db_table_and_field} <> '' AND CAST(CASE #{db_table_and_field} WHEN '' THEN '0' ELSE #{db_table_and_field} END AS decimal(30,3)) BETWEEN #{value[0].to_f} AND #{value[1].to_f})"
              else
                sql = "#{db_table_and_field} BETWEEN #{value[0].to_f} AND #{value[1].to_f}"
              end
            end
          when "o"
            sql = "#{queried_table_name}.status_id IN (SELECT id FROM #{IssueStatus.table_name} WHERE is_closed=#{self.class.connection.quoted_false})" if field == "status_id"
          when "c"
            sql = "#{queried_table_name}.status_id IN (SELECT id FROM #{IssueStatus.table_name} WHERE is_closed=#{self.class.connection.quoted_true})" if field == "status_id"
          when "><t-"
            # between today - n days and today
            sql = relative_date_clause(db_table, db_field, - value.first.to_i, 0, is_custom_filter)
          when ">t-"
            # >= today - n days
            sql = relative_date_clause(db_table, db_field, - value.first.to_i, nil, is_custom_filter)
          when "<t-"
            # <= today - n days
            sql = relative_date_clause(db_table, db_field, nil, - value.first.to_i, is_custom_filter)
          when "t-"
            # = n days in past
            sql = relative_date_clause(db_table, db_field, - value.first.to_i, - value.first.to_i, is_custom_filter)
          when "><t+"
            # between today and today + n days
            sql = relative_date_clause(db_table, db_field, 0, value.first.to_i, is_custom_filter)
          when ">t+"
            # >= today + n days
            sql = relative_date_clause(db_table, db_field, value.first.to_i, nil, is_custom_filter)
          when "<t+"
            # <= today + n days
            sql = relative_date_clause(db_table, db_field, nil, value.first.to_i, is_custom_filter)
          when "t+"
            # = today + n days
            sql = relative_date_clause(db_table, db_field, value.first.to_i, value.first.to_i, is_custom_filter)
          when "t"
            # = today
            sql = relative_date_clause(db_table, db_field, 0, 0, is_custom_filter)
          when "ld"
            # = yesterday
            sql = relative_date_clause(db_table, db_field, -1, -1, is_custom_filter)
          when "w"
            # = this week
            first_day_of_week = l(:general_first_day_of_week).to_i
            day_of_week = User.current.today.cwday
            days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
            sql = relative_date_clause(db_table, db_field, - days_ago, - days_ago + 6, is_custom_filter)
          when "lw"
            # = last week
            first_day_of_week = l(:general_first_day_of_week).to_i
            day_of_week = User.current.today.cwday
            days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
            sql = relative_date_clause(db_table, db_field, - days_ago - 7, - days_ago - 1, is_custom_filter)
          when "l2w"
            # = last 2 weeks
            first_day_of_week = l(:general_first_day_of_week).to_i
            day_of_week = User.current.today.cwday
            days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
            sql = relative_date_clause(db_table, db_field, - days_ago - 14, - days_ago - 1, is_custom_filter)
          when "m"
            # = this month
            date = User.current.today
            sql = date_clause(db_table, db_field, date.beginning_of_month, date.end_of_month, is_custom_filter)
          when "lm"
            # = last month
            date = User.current.today.prev_month
            sql = date_clause(db_table, db_field, date.beginning_of_month, date.end_of_month, is_custom_filter)
          when "y"
            # = this year
            date = User.current.today
            sql = date_clause(db_table, db_field, date.beginning_of_year, date.end_of_year, is_custom_filter)
          when "~"
            sql = sql_contains("#{db_table_and_field}", value.first)
          when "!~"
            sql = sql_contains("#{db_table_and_field}", value.first, false)
          else
            raise "Unknown query operator #{operator}"
          end

          return sql
        end
        private :sql_for_field


        # 8/ OVERRIDEN rewritten PRIVATE RM 4.0.0 OK
        # must be here in the parent Query class
        # Smile specific #354800 Requête perso Demandes / Rapport / Historiques : filtre projet mis-à-jour
        # Smile specific : manage case where db_table param is not provided
        #
        # Returns a SQL clause for a date or datetime field.
        def date_clause(table, field, from, to, is_custom_filter)
          s = []
          ################
          # Smile specific : table can be empty
          if table.present?
            table_field = "#{table}.#{field}"
          else
            table_field = "#{field}"
          end
          # END -- Smile specific : table can be empty
          #######################

          if from
            if from.is_a?(Date)
              from = date_for_user_time_zone(from.year, from.month, from.day).yesterday.end_of_day
            else
              from = from - 1 # second
            end
            if self.class.default_timezone == :utc
              from = from.utc
            end
            # Smile specific : table can be empty
            s << ("#{table_field} > '%s'" % [quoted_time(from, is_custom_filter)])
          end
          if to
            if to.is_a?(Date)
              to = date_for_user_time_zone(to.year, to.month, to.day).end_of_day
            end
            if self.class.default_timezone == :utc
              to = to.utc
            end
            # Smile specific : table can be empty
            s << ("#{table_field} <= '%s'" % [quoted_time(to, is_custom_filter)])
          end
          s.join(' AND ')
        end
        private :date_clause

        # 9/ COPIED from project_statement RM 4.0.0 OK
        def filter_column_on_projects(column_name)
          project_clauses = []
          active_subprojects_ids = []

          active_subprojects_ids = project.descendants.active.map(&:id) if project

          if active_subprojects_ids.any?
            if has_filter?("subproject_id")
              case operator_for("subproject_id")
              when '='
                # include the selected subprojects
                ids = [project.id] + values_for("subproject_id").map(&:to_i)
                project_clauses << "#{column_name} IN (%s)" % ids.join(',')
              when '!'
                # exclude the selected subprojects
                ids = [project.id] + active_subprojects_ids - values_for("subproject_id").map(&:to_i)
                project_clauses << "#{column_name} IN (%s)" % ids.join(',')
              when '!*'
                # main project only
                project_clauses << "#{column_name} = %d" % project.id
              else
                # all subprojects
                ids = [project.id] + project.descendants.collect(&:id)
                project_clauses << "#{column_name} IN (%s)" % ids.join(',')
              end
            elsif Setting.display_subprojects_issues?
              ids = [project.id] + project.descendants.collect(&:id)
              project_clauses << "#{column_name} IN (%s)" % ids.join(',')
            end
          elsif project
            project_clauses << "#{column_name} = %d" % project.id
          end
          project_clauses.any? ? project_clauses.join(' AND ') : nil
        end

        # 10/ new method, RM 4.0.0 OK
        # Smile specific #354800 Requête perso Demandes / Rapport / Historiques : filtre projet mis-à-jour
        # Smile specific : No table, calculated with sub-select
        def sql_for_project_updated_on_field(field, operator, value)
          # db_table empty
          db_field = "IFNULL(projects_updated_on_from_issues_by_project_id.project_updated_on, #{Issue.table_name}.created_on)"
          sql_for_field(field, operator, value, '', db_field)
        end

        # 11/ new method, RM 2.6 OK
        # Smile specific #271407 Time Entries : filter by BU
        def sql_for_bu_project_field(field, operator, value)
          sql_for_field(field, operator, value, 'bu_project_id', 'customized_id')
        end

        # 12/ new method, RM 2.3.2 OK
        # Smile specific #147568: Filter on parent task
        def sql_for_children_count_field(field, operator, value)
          # db_table empty
          db_field = "(#{Issue.table_name}.rgt - #{Issue.table_name}.lft - 1) / 2"
          sql_for_field(field, operator, value, '', db_field)
        end

        # 13/ new method, RM 2.6 OK
        # Smile specific #245660 Filter sub-tasks by depth in a tree
        def sql_for_level_in_tree_field(field, operator, value)
          # db_table empty
          db_field = "(SELECT COUNT(*) FROM #{Issue.table_name} AS ancestors WHERE " +
            "ancestors.root_id = #{Issue.table_name}.root_id AND " +
            "ancestors.lft < #{Issue.table_name}.lft AND " +
            "#{Issue.table_name}.rgt < ancestors.rgt)"

          sql_for_field(field, operator, value, '', db_field)
        end

        ################
        # Smile specific #340206 Filtre additifs
        # 14/ REWRITTEN, RM V4.0.0 OK
        def statement
          # filters clauses
          filters_clauses = []
          filters.each_key do |field|
            next if field == "subproject_id"
            v = values_for(field).clone
            next unless v and !v.empty?
            operator = operator_for(field)

            # "me" value substitution
            if %w(assigned_to_id author_id user_id watcher_id updated_by last_updated_by).include?(field)
              if v.delete("me")
                if User.current.logged?
                  v.push(User.current.id.to_s)
                  v += User.current.group_ids.map(&:to_s) if field == 'assigned_to_id'
                else
                  v.push("0")
                end
              end
            end

            if field == 'project_id'
              if v.delete('mine')
                v += User.current.memberships.map(&:project_id).map(&:to_s)
              end
            end

            if field =~ /^cf_(\d+)\.cf_(\d+)$/
              filters_clauses << sql_for_chained_custom_field(field, operator, v, $1, $2)
            elsif field =~ /cf_(\d+)$/
              # custom field
              filters_clauses << sql_for_custom_field(field, operator, v, $1)
            elsif field =~ /^cf_(\d+)\.(.+)$/
              filters_clauses << sql_for_custom_field_attribute(field, operator, v, $1, $2)
            elsif respond_to?(method = "sql_for_#{field.tr('.','_')}_field")
              # specific statement
              filters_clauses << send(method, field, operator, v)
            else
              # regular field
              filters_clauses << '(' + sql_for_field(field, operator, v, queried_table_name, field) + ')'
            end
          end if filters and valid?

          if (c = group_by_column) && c.is_a?(QueryCustomFieldColumn)
            # Excludes results for which the grouped custom field is not visible
            filters_clauses << c.custom_field.visibility_by_project_condition
          end

          ################
          # Smile specific #340206 Filtre additifs
          # Or filters clauses
          or_filters_clauses = []
          if self.class.respond_to?(:or_filters_provided?)
            or_filters.each_key do |field|
              next if field == "subproject_id"
              v = or_values_for(field).clone
              next unless v and !v.empty?
              operator = or_operator_for(field)

              # "me" value substitution
              ################
              # Smile specific : +old_value fields for Indicators
              # TODO Jebat Indicators NOT in Time Entry Query
              # * old_value_assigned_to_id
              # * old_value_author_id
              # * old_value_user_id
              # * old_value_watcher_id
              if %w(assigned_to_id old_value_assigned_to_id author_id old_value_author_id user_id old_value_user_id watcher_id old_value_watcher_id).include?(field)
                if v.delete("me")
                  if User.current.logged?
                    v.push(User.current.id.to_s)
                    v += User.current.group_ids.map(&:to_s) if field == 'assigned_to_id'
                  else
                    v.push("0")
                  end
                end
              end

              if field == 'project_id'
                if v.delete('mine')
                  v += User.current.memberships.map(&:project_id).map(&:to_s)
                end
              end

              if field =~ /^cf_(\d+)\.cf_(\d+)$/
                or_filters_clauses << sql_for_chained_custom_field(field, operator, v, $1, $2)
              elsif field =~ /cf_(\d+)$/
                # custom field
                or_filters_clauses << sql_for_custom_field(field, operator, v, $1)
              elsif field =~ /^cf_(\d+)\.(.+)$/
                filters_clauses << sql_for_custom_field_attribute(field, operator, v, $1, $2)
              elsif respond_to?(method = "sql_for_#{field.tr('.','_')}_field")
                # specific statement
                or_filters_clauses << send(method, field, operator, v)
              else
                # regular field
                or_filters_clauses << '(' + sql_for_field(field, operator, v, queried_table_name, field) + ')'
              end
            end if or_filters and valid?

            if (c = group_by_column) && c.is_a?(QueryCustomFieldColumn)
              # Excludes results for which the grouped custom field is not visible
              or_filters_clauses << c.custom_field.visibility_by_project_condition
            end
            or_filters_clauses.reject!(&:blank?)
          end
          # END -- Smile specific #340206 Filtre additifs
          #######################

          filters_clauses << project_statement
          filters_clauses.reject!(&:blank?)

          result_statement = filters_clauses.any? ? filters_clauses.join(' AND ') : nil

          ################
          # Smile specific #340206 Filtre additifs
          if or_filters_clauses.any?
            if filters_clauses.any?
              result_statement += ' AND (' + or_filters_clauses.join(' OR ') + ')'
            else
              result_statement = or_filters_clauses.join(' OR ')
            end
          end
          # END -- Smile specific #340206 Filtre additifs
          #######################

          result_statement
        end

        # 15/ REWRITTEN, RM 4.0.0 OK
        # Smile specific #768870 V4.0.0 : Query, Subproject filter, do not include current project by default
        # Smile specific : +param with_parent
        # Smile specific : sort sub-projects (order(:name))
        def subproject_values(with_current=false)
          # Smile specific#768870 V4.0.0 : Query, Subproject filter, do not include current project by default
          # Smile specific : with self option
          if with_current
            projects_scope = project.self_and_descendants
          else
            projects_scope = project.descendants
          end

          projects_scope.
            visible(User.current, subproject_values_condition_hook). # Hook for overrides
            order(:name). # Smile specific : sort sub-projects (order(:name))
            collect{|s| [s.name, s.id.to_s] }
        end

        # 16/ new method, RM 4.0.0 OK
        # Smile specific : a new hook
        def subproject_values_condition_hook
          {}
        end

        # 17/ new method, RM 4.0.0 OK
        # Smile specific #52117 Droit relais, accès aux sous-projets
        # Smile specific #994 Budget and Remaining enhancement
        # TODO move relay role in hook
        # Smile comment : cached
        def project_and_children_ids
          return @project_and_children_ids if defined?(@project_and_children_ids)

          @project_and_children_ids = []

          return @project_and_children_ids unless project

          # Smile specific #994 Budget and Remaining enhancement
          @project_and_children_ids << project.id

          ################
          # Smile specific #52117 Droit relais, accès aux sous-projets
          if User.current.respond_to?('relay_role_visible_conditions')
            _relay_role_visible_conditions = User.current.relay_role_visible_conditions(project)
          else
            _relay_role_visible_conditions = {}
          end
          # END -- Smile specific #52117 Droit relais, accès aux sous-projets
          ##############################

          @project_and_children_ids += project.descendants.visible( User.current, _relay_role_visible_conditions ).pluck(:id) unless project.leaf?

          @project_and_children_ids
        end

        # 18/ new method, RM 4.0.0 OK
        # Smile specific #994 Budget and Remaining enhancement
        # Smile comment : cached
        def project_and_children
          return @project_and_children if defined?(@project_and_children)

          # Smile specific #994 Budget and Remaining enhancement
          @project_and_children = Project.where(:id => project_and_children_ids)

          @project_and_children
        end

        # 19/ new method, RM 4.0.0 OK
        # TODO move relay role in hook
        # Smile specific #147568 Filter on parent task
        # Smile specific #52117 Droit relais, accès aux sous-projets
        # Smile specific #247451 Entrées de temps et Rapport : filtre par demande
        # Smile specific #994 Budget and Remaining enhancement
        def calc_project_and_children_issues
          return if defined?(@children_root_issues_id_and_label)

          ################
          # Smile specific #147568 Filter on parent task
          @children_root_issues_id_and_label   = []
          @children_parent_issues_id_and_label = []
          @children_issues_id_and_label        = []


          ################
          # Smile specific #52117 Droit relais, accès aux sous-projets
          if User.current.respond_to?('relay_role_visible_conditions')
            _relay_role_visible_conditions = User.current.relay_role_visible_conditions(project)
          else
            _relay_role_visible_conditions = {}
          end
          # END -- Smile specific #52117 Droit relais, accès aux sous-projets
          #######################

          project_and_children_all_issues = Issue.where(
              :project_id => project_and_children_ids
            # Smile specific #52117 Relay role (visible params)
            ).visible(
              User.current, _relay_role_visible_conditions
            ).
            select(
              ["#{Issue.table_name}.id", :subject, "#{Issue.table_name}.parent_id", "#{Issue.table_name}.lft", "#{Issue.table_name}.rgt"] # lft, rgt needed for leaf?
            )

          project_and_children_all_issues.each do |issue|
            issue_id_and_label                 = nil
            issue_having_children_id_and_label = nil
            issue_being_root_id_and_label      = nil

            # Smile specific #751025 V4.0.0 : Query filters, Issue, Parent, Root list with children count
            children_count = ((issue.rgt - issue.lft - 1) / 2)
            # Smile specific #393868 Filtres requête perso. : tronquer à 60 cars titre demande
            issue_id_and_label = ["##{issue.id} #{issue.subject.truncate(60)} [#{children_count}] #{l(:label_subtask_plural)}", issue.id.to_s]

            # All issues
            # Issues with children (parents)
            unless issue.leaf?
              issue_having_children_id_and_label = issue_id_and_label
            end

            # Root issues
            if issue.parent_id.blank?
              issue_being_root_id_and_label = issue_id_and_label
            end

            @children_root_issues_id_and_label   << issue_being_root_id_and_label if issue_being_root_id_and_label
            @children_parent_issues_id_and_label << issue_having_children_id_and_label if issue_having_children_id_and_label
            @children_issues_id_and_label        << issue_id_and_label
          end

          @children_root_issues_id_and_label.uniq!
          @children_parent_issues_id_and_label.uniq!
          @children_issues_id_and_label.uniq!

          # Smile specific : newest issues first
          # Sort on the second element of the hash : id,
          @children_root_issues_id_and_label.sort!{|a, b| b.second.to_i <=> a.second.to_i}
          @children_parent_issues_id_and_label.sort!{|a, b| b.second.to_i <=> a.second.to_i}
          @children_issues_id_and_label.sort!{|a, b| b.second.to_i <=> a.second.to_i}
        end

        # 20/ EXTENDED, RM 4.0.0 OK
        # Smile specific #763000 Totalable colums : hide checkbox if not enable on project nor sub-projects
        # Smile specific : Hide custom fields that are not enabled on project nor its sub-projects
        # TODO : remove, already done upstream
        # Smile specific : cached
        def available_totalable_columns_DISABLED
          return @available_totalable_columns if defined?(@available_totalable_columns)

          if project
            @available_totalable_columns = super
            @available_totalable_columns.select! do |tc|
              project_rolled_up_custom_fields = project.rolled_up_custom_fields
              if tc.is_a?(QueryCustomFieldColumn)
                project.rolled_up_custom_fields.include?(tc.custom_field)
              else
                true
              end
            end

            @available_totalable_columns
          else
            @available_totalable_columns = super
          end
        end

        # 21/ REWRITTEN, RM 4.0.0 OK
        # Smile specific #768870 V4.0.0 : Query, Subproject filter, do not include current project by default
        # Smile specific : subproject_id, do not include current project
        def project_statement
          project_clauses = []
          active_subprojects_ids = []

          active_subprojects_ids = project.descendants.active.map(&:id) if project
          if active_subprojects_ids.any?
            if has_filter?("subproject_id")
              case operator_for("subproject_id")
              when '='
                # include the selected subprojects
                ################
                # Smile specific : [project.id] + removed
                ids = values_for("subproject_id").map(&:to_i)
                project_clauses << "#{Project.table_name}.id IN (%s)" % ids.join(',')
              when '!'
                # exclude the selected subprojects

                ################
                # Smile specific : [project.id] + removed
                ids = active_subprojects_ids - values_for("subproject_id").map(&:to_i)
                project_clauses << "#{Project.table_name}.id IN (%s)" % ids.join(',')
              when '!*'
                # main project only
                project_clauses << "#{Project.table_name}.id = %d" % project.id
              else
                # all subprojects
                project_clauses << "#{Project.table_name}.lft >= #{project.lft} AND #{Project.table_name}.rgt <= #{project.rgt}"
              end
            elsif Setting.display_subprojects_issues?
              project_clauses << "#{Project.table_name}.lft >= #{project.lft} AND #{Project.table_name}.rgt <= #{project.rgt}"
            else
              project_clauses << "#{Project.table_name}.id = %d" % project.id
            end
          elsif project
            project_clauses << "#{Project.table_name}.id = %d" % project.id
          end
          project_clauses.any? ? project_clauses.join(' AND ') : nil
        end

        # 22/ REWRITTEN, RM 4.0.0 OK
        # TODO remove
        # Overrides Query.total_for to add more joins
        # Smile specific #994 Budget and Remaining enhancement
        # Smile specific #758281 V4.0.0 : Query Totals needs filter additionnal queries
        # Smile specific : + only_visible param
        # Smile specific : cached by only_visible AND column
        #
        # Returns the sum of values for the given column
        def total_for(column, only_visible=true)
          ################
          # Smile specific : cache by only_visible AND column + COMPOSITE columns
          return nil unless column

          #-----------------------------
          # Smile specific : debug trace
          debug = nil
          if self.respond_to?('debug')
            debug = self.debug
          end

          @total_for_by_column ||= {true => {}, false => {}}

          if @total_for_by_column[only_visible][column.name]
            logger.debug "==>prof     #{@indent_spaces}from CACHE total_for(#{column.name}, ...#{', NOT only_visible' unless only_visible})" if debug

            return @total_for_by_column[only_visible][column.name]
          end

          if self.respond_to?('total_for_bar')
            total_for_bar(column, only_visible, @total_for_by_column, :total_for)
          end

          if @total_for_by_column[only_visible][column.name]
            return @total_for_by_column[only_visible][column.name]
          end
          # END -- Smile specific : cache by only_visible AND column + COMPOSITE columns
          #######################

          if debug
            start = Time.now

            logger.debug " =>prof"
            logger.debug "\\=>prof     #{@indent_spaces}total_for(#{column.name}#{', NOT only_visible' unless only_visible}) NATIVE"
          end

          the_scope = base_scope

          ################
          # Smile specific #994 Budget and Remaining enhancement
          if respond_to?(:joins_additionnal)
            # Smile comment : does NOT need joins for order_option here
            the_scope = the_scope.joins( joins_additionnal(nil) )
          end
          # END -- Smile specific #994 Budget and Remaining enhancement
          #######################

          ################
          # Smile specific : + param only_visible
          @total_for_by_column[only_visible][column.name] = total_with_scope(column, the_scope, only_visible)

          #-----------------------------
          # Smile specific : debug trace
          if debug
            logger.debug "/=>prof     #{@indent_spaces}total_for(#{column.name}#{', NOT only_visible' unless only_visible}) -- #{format_duration(Time.now - start, true)}"
          end

          ################
          # Smile specific : cache
          @total_for_by_column[only_visible][column.name]
        end

        # 23/ REWRITTEN, RM 4.0.0 OK
        # TODO remove total_by_group_for in this plugin
        # Smile specific #772964 V4.0.0 : Issues Pdf export : bar totals lead to error 500
        # Smile specific : + only_visible param
        # Smile specific : cached by only_visible AND column
        # Smile specific : calls itself on sub-columns for BAR COMPOSITE columns
        #
        # Returns a hash of the sum of the given column for each group,
        # or nil if the query is not grouped
        def total_by_group_for(column, only_visible=true)
          ################
          # Smile specific : cache
          return nil unless column

          @total_by_group_for_by_column ||= {true => {}, false => {}}

          if @total_by_group_for_by_column[only_visible][column.name]
            logger.debug "==>prof       #{@indent_spaces}from CACHE total_for(#{column.name}, ...#{', NOT only_visible' unless only_visible})" if debug

            return @total_by_group_for_by_column[only_visible][column.name]
          end
          # END -- Smile specific : cache
          #######################

          ################
          # Smile specific : manage composite Issue Columns
          if self.respond_to?('total_for_bar')
            total_for_bar(column, only_visible, @total_by_group_for_by_column, :total_by_group_for)
          end

          if @total_by_group_for_by_column[only_visible][column.name]
            return @total_by_group_for_by_column[only_visible][column.name]
          end
          # END -- Smile specific : manage composite Issue Columns
          #######################


          #-----------------------------
          # Smile specific : debug trace
          debug = nil
          if self.respond_to?('debug')
            debug = self.debug
          end

          if debug
            start = Time.now

            logger.debug " =>prof"
            logger.debug "\\=>prof       #{@indent_spaces}total_by_group_for(#{column.name}#{', NOT only_visible' unless only_visible}) NATIVE"
          end

          ################
          # Smile specific : cache
          # Smile comment : UPSTREAM CODE
          @total_by_group_for_by_column[only_visible][column.name] = grouped_query do |scope|
            ################
            # Smile specific : + param only_visible
            total_with_scope(column, scope, only_visible)
          end

          #-----------------------------
          # Smile specific : debug trace
          if debug
            logger.debug "/=>prof       #{@indent_spaces}total_by_group_for(#{column.name}#{', NOT only_visible' unless only_visible}) -- #{format_duration(Time.now - start, true)}"
          end

          ################
          # Smile specific : cache
          @total_by_group_for_by_column[only_visible][column.name]
        end

        # 24/ REWRITTEN, RM 4.0.0 OK
        # TODO remove total_with_scope ?
        # Smile specific : manage only_visible case
        # Smile specific : only pass visible param to total_for_* send call
        def total_with_scope(column, scope, only_visible=true)
          #-----------------------------
          # Smile specific : debug trace
          debug = nil
          if self.respond_to?('debug')
            debug = self.debug
          end

          unless column.is_a?(QueryColumn)
            column = column.to_sym
            column = available_totalable_columns.detect {|c| c.name == column}
          end
          if column.is_a?(QueryCustomFieldColumn)
            custom_field = column.custom_field
            send "total_for_custom_field", custom_field, scope
          else
            if is_a?(IssueQuery)
              ################
              # Smile specific : manage only_visible case
              # Smile specific : + debug param
              logger.debug " =>prof       IQ total_with_scope  send total_for_#{column.name}, scope, only_visible=#{only_visible ? 'true' : 'false'}" if debug
              if only_visible
                # Smile comment : UPSTREAM CODE
                send "total_for_#{column.name}", scope
              else
                logger.debug " =>prof       IQ total_with_scope  +joins_additionnal" if debug
                # Smile comment : to be able to calculate totals on not visible issues
                send "total_for_#{column.name}", scope, false
              end
              # END -- Smile specific
              #######################
            else
              # Smile comment : UPSTREAM CODE
              send "total_for_#{column.name}", scope
            end
          end
          # Smile specific : Namespace prefix, in a sub-module
        rescue ::ActiveRecord::StatementInvalid => e
          raise ::ActiveRecord::StatementInvalid.new(e.message)
        end
        private :total_with_scope

        # 25/ new method, RM 4.0.0 OK
        # Smile specific #994 Budget and remaining enhancement
        def sql_visible_time_entries_issues_ids(project_ids, debug=false)
          sql_issue_ids = Issue.joins(:project).
            where( TimeEntry.visible_condition(User.current) )

          sql_issue_ids = sql_issue_ids.where(project_ids) if project_ids

          logger.debug(" =>prof       sql_visible_time_entries_issues_ids [#{sql_issue_ids.count}] issues") if debug

          sql_issue_ids = sql_issue_ids.
            order(:id).
            pluck(:id).
            join(',')
        end


        ################
        # Smile specific #340206 Filtre additifs
        # 40/ New method
        def add_or_filter(field, operator, values=nil)
          # values must be an array
          return unless values.nil? || values.is_a?(Array)
          # check if field is defined as an available filter
          if available_filters.has_key? field
            filter_options = available_filters[field]
            or_filters[field] = {:operator => operator, :values => (values || [''])}
          end
        end

        # 41/ New method
        #
        # Add multiple *or* filters using +add_filter+
        def add_or_filters(fields, operators, values)
          if fields.present? && operators.present?
            fields.each do |field|
              # Smile specific #340206 Filtre additifs
              add_or_filter(field, operators[field], values && values[field])
            end
          end
        end

        # 42/ New method
        def has_or_filter?(field)
          or_filters and or_filters[field]
        end

        # 43/ REWRITTEN RM V4.0.0 OK
        # New optional param or_filter
        def add_filter_error(field, message, or_filter=false)
          m = label_for(field) + " #{or_filter ? " (#{l(:label_or_filters)}) " : ''}" + l(message, :scope => 'activerecord.errors.messages')
          errors.add(:base, m)
        end

        # 44/ New method
        def or_operator_for(field)
          has_or_filter?(field) ? or_filters[field][:operator] : nil
        end

        # 45/ New method
        def or_values_for(field)
          has_or_filter?(field) ? or_filters[field][:values] : nil
        end

        # 46/ New method
        def or_value_for(field, index=0)
          (or_values_for(field) || [])[index]
        end

        # 47/ EXTENDED RM V4.0.0 OK
        def validate_query_filters
          super

          or_filters.each_key do |field|
            if values_for(field)
              case type_for(field)
              when :integer
                add_filter_error(field, :invalid, true) if or_values_for(field).detect {|v| v.present? && !v.match(/\A[+-]?\d+(,[+-]?\d+)*\z/) }
              when :float
                add_filter_error(field, :invalid, true) if or_values_for(field).detect {|v| v.present? && !v.match(/\A[+-]?\d+(\.\d*)?\z/) }
              when :date, :date_past
                case or_operator_for(field)
                when "=", ">=", "<=", "><"
                  add_filter_error(field, :invalid, true) if or_values_for(field).detect {|v|
                    v.present? && (!v.match(/\A\d{4}-\d{2}-\d{2}(T\d{2}((:)?\d{2}){0,2}(Z|\d{2}:?\d{2})?)?\z/) || parse_date(v).nil?)
                  }
                when ">t-", "<t-", "t-", ">t+", "<t+", "t+", "><t+", "><t-"
                  add_filter_error(field, :invalid, true) if or_values_for(field).detect {|v| v.present? && !v.match(/^\d+$/) }
                end
              end
            end

            add_filter_error(field, :blank, true) unless
                # filter requires one or more values
                (or_values_for(field) and !or_values_for(field).first.blank?) or
                # filter doesn't require any value
                ["o", "c", "!*", "*", "t", "ld", "w", "lw", "l2w", "m", "lm", "y", "*o", "!o"].include? or_operator_for(field)
          end if or_filters && or_filters.respond_to?(:each_key)
        end

        # 48/ New method
        # Smile specific : garanties it is not nil
        def or_filters
          read_attribute('or_filters') || {}
        end
        # END -- Smile specific #340206 Filtre additifs
        #######################


        module ClassMethods
          # 1/ new method, RM 4.0.0 OK
          def with_children_provided?
            false
          end

          # 2/ new method, RM 4.0.0 OK
          def group_additional_infos_provided?
            false
          end

          # 3/ new method, RM 4.0.0 OK
          # Smile Specific #354800 Requête perso Demandes / Rapport / Historiques : filtre projet mis-à-jour
          def sql_projects_updated_on_from_issues_by_project
            return @@sql_projects_updated_on_from_issues_by_project if defined?(@@sql_projects_updated_on_from_issues_by_project)

            @@sql_projects_updated_on_from_issues_by_project =
            '(' +
              'SELECT i.project_id AS project_updated_on_id, MAX(i.updated_on) AS project_updated_on ' +
              "FROM #{Issue.table_name} AS i " +
              'WHERE' +
              ' %s ' +
              'GROUP BY i.project_id ' +
            ') AS projects_updated_on_from_issues_by_project_id'
          end

          # 4/ new method, RM 4.0.0 OK
          # Smile specific #354800 Requête perso Demandes / Rapport / Historiques : filtre projet mis-à-jour
          def left_join_project_updated_on_from_issues(sql_projects_select)
            'LEFT OUTER JOIN ' +
              (sql_projects_updated_on_from_issues_by_project % sql_projects_select) +
              " ON (projects_updated_on_from_issues_by_project_id.project_updated_on_id = #{Project.table_name}.id)"
          end


          # 5/ new method, RM 4.0.0 OK
          def advanced_filters_provided?
            true
          end

          # 6/ new method, RM 4.0.0 OK
          def or_filters_provided?
            true
          end

          # 7/ new method, RM 4.0.0 OK
          def sql_in_values_or_false_if_empty(in_values, prefix='', parenthesis=nil)
            if in_values.empty?
              sql_in_values = '1=0'
              sql_in_values = "(#{sql_in_values})" if parenthesis
              return sql_in_values
            end

            sql_in_values = "#{prefix} IN (#{in_values})"
            sql_in_values = "(#{sql_in_values})" if parenthesis
            sql_in_values
          end

          # 8/ new method, RM 4.0.0 OK
          def sql_where_w_optional_conditions(where_prefix, cond1, cond2=nil, cond3=nil)
            return '' unless cond1.present? || cond2.present? || cond3.present?

            if where_prefix
              sql_where = ' WHERE '
            else
              sql_where = ' AND '
            end

            sql_where += cond1 if cond1.present?

            if cond2.present?
              sql_where += ' AND ' if cond1.present?
              sql_where += cond2
            end

            if cond3.present?
              sql_where += ' AND ' if cond1.present? || cond2.present?
              sql_where += cond3
            end

            sql_where
          end
        end # module ClassMethods
      end # module ExtendedQueries

      #*****************************
      # 2/ ForbidPublicGlobalQueries
      module ForbidPublicGlobalQueries
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1/ Instance methods
          enhancements_instance_methods = [
            # Following Protected

            #                                      50/ new method
            :validate_setting_public_query_for_all_projects_forbidden,
          ]

          trace_prefix = "#{' ' * (base.name.length + 27)}  --->  "
          last_postfix = '< (SM::MO::QueryOverride::ForbidPublicGlobalQueries)'


          smile_instance_methods = base.public_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }
          smile_instance_methods += base.protected_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          smile_instance_methods += base.private_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = enhancements_instance_methods.select{|m|
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
            last_postfix
          )

          if missing_instance_methods.any?
            raise trace_first_prefix + missing_instance_methods.join(', ') + '  ' + last_postfix
          end

          ####################
          # 2/ New validations
          base.instance_eval do
            # Smile specific #346641 Forbid setting query public to others than me for non-admins
            validate :validate_setting_public_query_for_all_projects_forbidden, :if => Proc.new { |q| q.new_record? || q.changed? }
          end

          new_validate_callback_names = [
            :validate_setting_public_query_for_all_projects_forbidden,
          ]

          validate_callback_names = base._validate_callbacks.collect{|cb| cb.send(:filter)}

          missing_validate_callback = new_validate_callback_names.select{|cb|
              ! validate_callback_names.include?(cb)
            }

          if missing_validate_callback.any?
            trace_first_prefix = "#{base.name} MISS                    validate  "

          else
            trace_first_prefix = "#{base.name}                         validate  "
          end

          SmileTools::trace_by_line(
            (
              missing_validate_callback.any? ?
              missing_validate_callback :
              new_validate_callback_names
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix
          )

          if missing_validate_callback.any?
            raise trace_first_prefix + missing_validate_callback.join(', ') + '  ' + last_postfix
          end
        end # def self.prepended


      protected

        # 50/ new method
        # Smile specific #346641 Forbid setting query public to others than me for non-admins
        def validate_setting_public_query_for_all_projects_forbidden
          if (
            !User.current.admin? &&
            visibility != Query::VISIBILITY_PRIVATE && # public query
            project_id == nil # for all
          )
            errors.add(:base, l(:field_is_for_all) + ' ' + l('activerecord.errors.messages.exclusion'))
          end
        end
      end # module ForbidPublicGlobalQueries
    end # module QueryOverride
  end # module Models
end # module Smile
