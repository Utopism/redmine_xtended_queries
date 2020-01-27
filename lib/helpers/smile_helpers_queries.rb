# Smile - queries_helper enhancement
#
# TESTED OK
#
# * #256456 Sauvegarder la case à cocher "Include sub-tasks time"
#   2015
# * #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
# * #100718 Liste demandes : total F / G / D au niveau de chaque groupe
# * #340206 Filtre additifs

# module Smile::Helpers::QueriesOverride
# - 1/ module ::ExtendedQueries

module Smile
  module Helpers
    module QueriesOverride
      #*******************
      # 1/ ExtendedQueries
      module ExtendedQueries
        def self.prepended(base)
          extended_queries_instance_methods = [
            # module_eval
            :retrieve_query,                              # 1/ REWRITTEN   TESTED  RM 4.0.0 OK
            :query_as_hidden_field_tags,                  # 2/ REWRITTEN   TESTED  RM 4.0.0 OK
            :grouped_query_results,                       # 3/ New method  TESTED  RM 4.0.0 OK
            :column_value_hook,                           # 4/ EXTENDED    TO TEST RM 4.0.0 OK
          ]


          # Methods dynamically added to QueriesHelper, source replaced by module_eval
          # Because we can't use normal methods override
          # => no access to super
          # 2012-01-18 no way to include a module in a module (like InstanceMethods)
          # QueryController
          #  -> has a dynamic module (accessible QueryController.with master_helper_module)
          #     -> includes all Controller helpers :
          #        including QueriesHelper
          #          -> includes modules included in the helpers
          #          -> Pb. 1 : includes the sub modules in the dynamic module => duplication !
          #             - methods already present in QueriesHelper -- OK
          #             - Pb. 2 : new methods in the modules included -- NON-OK
          base.module_eval do # <<READER, __FILE__, (__LINE__ + 1) #does not work
            # 1/ REWRITTEN, RM 4.0.0 OK
            # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
            # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
            # Smile specific #340206 Filtre additifs
            #
            # Retrieve query from session or build a new query
            def retrieve_query(klass=IssueQuery, use_session=true, options={})
              session_key = klass.name.underscore.to_sym

              if params[:query_id].present?
                cond = "project_id IS NULL"
                cond << " OR project_id = #{@project.id}" if @project
                @query = klass.where(cond).find(params[:query_id])
                raise ::Unauthorized unless @query.visible?
                @query.project = @project
                session[session_key] = {:id => @query.id, :project_id => @query.project_id} if use_session
              elsif api_request? || params[:set_filter] || !use_session || session[session_key].nil? || session[session_key][:project_id] != (@project ? @project.id : nil)
                # Give it a name, required to be valid
                @query = klass.new(:name => "_", :project => @project)

                @query.build_from_params(params, options[:defaults])

                ################
                # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
                # Smile specific #340206 Filtre additifs
                # Added with_children and group_additional_infos
                with_children = nil
                if Query.respond_to?('with_children_provided?') && Query.with_children_provided?
                  with_children = @query.with_children
                end

                group_additional_infos = nil
                if Query.respond_to?('group_additional_infos_provided?') && Query.group_additional_infos_provided?
                  group_additional_infos = @query.group_additional_infos
                end

                advanced_filters = nil
                if @query.respond_to?('advanced_filters')
                  advanced_filters = @query.advanced_filters
                end

                session[session_key] = {
                  :project_id => @query.project_id,
                  :filters => @query.filters,
                  ################
                  # Smile specific : new options, or_filters
                  # Smile specific #340206 Filtre additifs
                  :or_filters => @query.or_filters,
                  :group_by => @query.group_by,
                  :column_names => @query.column_names,
                  :totalable_names => @query.totalable_names,
                  :sort => @query.sort_criteria.to_a,

                  ################
                  # Smile specific : new options
                  :with_children => (with_children ? '1' : nil),
                  :group_additional_infos => (group_additional_infos ? '1' : nil),
                  # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
                  :advanced_filters => (advanced_filters ? '1' : nil)
                } if use_session

                if use_session && @query.respond_to?('hours_by_day')
                  session[session_key][:hours_by_day] = @query.hours_by_day
                end
                # END -- Smile specific : new options
                #######################
              else
                # retrieve from session
                @query = nil
                @query = klass.find_by_id(session[session_key][:id]) if session[session_key][:id]
                ################
                # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
                # Added with_children and group_additional_infos
                @query ||= klass.new(:name => "_",
                  :filters => session[session_key][:filters],
                  ################
                  # Smile specific : new options
                  # Smile specific #340206 Filtre additifs
                  :or_filters => session[session_key][:or_filters],
                  :group_by => session[session_key][:group_by],
                  :column_names => session[session_key][:column_names],
                  :totalable_names => session[session_key][:totalable_names],
                  :sort_criteria => session[session_key][:sort],

                  ################
                  # Smile specific : new options
                  :with_children => (session[session_key][:with_children] ? '1' : nil),
                  :group_additional_infos => (session[session_key][:group_additional_infos] ? '1' : nil),
                )

                # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
                if @query.respond_to?('advanced_filters')
                  @query.advanced_filters = (session[session_key][:advanced_filters] ? '1' : nil)
                end

                if @query.respond_to?('hours_by_day')
                  @query.hours_by_day = session[session_key][:hours_by_day]
                end
                # END -- Smile specific : new options
                #######################

                @query.project = @project
              end
              if params[:sort].present?
                @query.sort_criteria = params[:sort]
                if use_session
                  session[session_key] ||= {}
                  session[session_key][:sort] = @query.sort_criteria.to_a
                end
              end
              @query
            end

            # 2/ REWRITTEN, RM 4.0.0 OK
            # Smile specific #256456 Sauvegarder la case à cocher "Include sub-tasks time"
            # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
            # Smile specific #100718 Liste demandes : total F / G / D au niveau de chaque groupe
            # Smile specific #340206 Filtre additifs
            #
            # Returns the query definition as hidden field tags
            def query_as_hidden_field_tags(query)
              tags = hidden_field_tag("set_filter", "1", :id => nil)

              if query.filters.present?
                query.filters.each do |field, filter|
                  tags << hidden_field_tag("f[]", field, :id => nil)
                  tags << hidden_field_tag("op[#{field}]", filter[:operator], :id => nil)
                  filter[:values].each do |value|
                    tags << hidden_field_tag("v[#{field}][]", value, :id => nil)
                  end
                end
              else
                tags << hidden_field_tag("f[]", "", :id => nil)
              end
              query.columns.each do |column|
                tags << hidden_field_tag("c[]", column.name, :id => nil)
              end
              if query.totalable_names.present?
                query.totalable_names.each do |name|
                  tags << hidden_field_tag("t[]", name, :id => nil)
                end
              end
              if query.group_by.present?
                tags << hidden_field_tag("group_by", query.group_by, :id => nil)
              end
              if query.sort_criteria.present?
                tags << hidden_field_tag("sort", query.sort_criteria.to_param, :id => nil)
              end

              if query.sort_criteria.present?
                tags << hidden_field_tag("sort", query.sort_criteria.to_param, :id => nil)
              end

              ################
              # Smile specific #340206 Filtre additifs
              if query.or_filters.present? && query.or_filters.any?
                tags << hidden_field_tag("or_filters", query.or_filters.to_param, :id => nil)
              end

              ################
              # Smile specific #340206 Filtre additifs
              if query.respond_to?('hours_by_day') && query.hours_by_day.present?
                tags << hidden_field_tag("hours_by_day", query.hours_by_day.to_param, :id => nil)
              end

              ################
              # Smile specific #340206 Filtre additifs
              if (
                Query.respond_to?('with_children_provided?') &&
                Query.with_children_provided?
              )
                tags << hidden_field_tag("with_children", (query.with_children ? '1' : ''), :id => nil)
              end

              ################
              # Smile specific #100718 Liste demandes : total F / G / D au niveau de chaque groupe
              if (
                Query.respond_to?('group_additional_infos_provided?') &&
                Query.group_additional_infos_provided?
              )
                tags << hidden_field_tag("group_additional_infos", (query.group_additional_infos ? '1' : ''), :id => nil)
              end

              ################
              # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
              if query.respond_to?('advanced_filters') && query.advanced_filters.present?
                tags << hidden_field_tag("advanced_filters", (query.advanced_filters ? '1' : ''), :id => nil)
              end

              ################
              # Smile specific debug stored in query
              debug = nil
              if query.respond_to?('debug')
                debug = query.debug
              end

              if debug.present?
                tags << hidden_field_tag("debug", debug.to_param, :id => nil)
              end

              logger.debug " =>prof   query_as_hidden_field_tags #{tags.inspect}" if debug == '3'

              tags
            end

            # 3/ REWRITTEN, RM 4.0.3 OK
            # TODO test grouped_query_results with and without redmine_smile_enhancements plugin
            # Smile specific #994 Budget and remaining enhancement
            # Smile specific #216009 Liste demandes : Compteur groupe vide, tâche racine / % avanct
            # Smile specific #100718 Liste demandes : total F / G / D au niveau de chaque groupe
            def grouped_query_results(items, query, &block)
              #---------------
              # Smile specific : profiling trace
              debug = params[:debug]
              if debug
                global_start = Time.now
              end
              logger.debug "==>prof" if debug
              logger.debug "\\=>prof     grouped_query_results" if debug
              # END -- Smile specific : profiling trace
              #----------------------

              result_count_by_group = query.result_count_by_group
              #---------------
              # Smile specific : debug trace
              logger.debug " =>prof        result_count_by_group keys=#{result_count_by_group ? result_count_by_group.keys.join(',') : 'NONE'}" if debug

              previous_group, first = false, true

              ################
              # Smile specific : to calculate it once
              issue_ids_by_group_value = nil

              ################
              # Smile specific #100718 Liste demandes : total F / G / D au niveau de chaque groupe
              # Smile specific : calculate totals_by_group
              if Query.respond_to?('group_additional_infos_provided?') && Query.group_additional_infos_provided?
                if query.group_additional_infos
                  logger.debug " =>prof       group_additional_infos OK" if debug
                  logger.debug " =>prof       grouped? #{query.grouped? ? 1 : 0}" if debug

                  totals_by_group = query.totalable_columns.inject({}) do |h, column|
                    ################
                    # Smile specific #994 Budget and remaining enhancement
                    # Smile specific : group totals for BAR columns, Optimized :
                    # * Use preloaded BAR values
                    # * Only on parent issues if with Children
                    logger.debug " =>prof   * #{column.name}" if query.grouped? && debug

                    total_by_group_for_column = query.total_by_group_for_column_for_issues(column, items)

                    if total_by_group_for_column.nil?
                      h[column] = query.total_by_group_for(column)
                    else
                      h[column] = total_by_group_for_column
                    end
                    # END -- Smile specific #994 Budget and remaining enhancement
                    #######################

                    ################
                    # Smile specific #994 Budget and remaining enhancement
                    # Smile specific : hours by day conversion
                    if (
                      query.hours_by_day && (query.hours_by_day != 0) &&
                      (
                        [:spent_hours, :estimated_hours].include?(column.name) ||
                        Query.bar_additional_time_column_names.include?(column.name)
                      )
                    )
                      if h[column]
                        h[column].each do |k, total|
                          h[column][k] = (total / query.hours_by_day) if total
                        end
                      end
                    end
                    # END -- Smile specific #994 Budget and remaining enhancement
                    #######################

                    h
                  end # totals_by_group = query.totalable_columns ...
                else
                  totals_by_group = nil
                end
              else
                #--------------
                # Smile comment : NATIVE Source Code
                totals_by_group = query.totalable_columns.inject({}) do |h, column|
                  h[column] = query.total_by_group_for(column)
                  h
                end
              end
              items.each do |item|
                #---------------
                # Smile specific : debug trace
                logger.debug " =>prof       #{item.id}" if debug == '2'
                group_name = group_count = nil
                if query.grouped?
                  column = query.group_by_column
                  #---------------
                  # Smile specific : split for debug trace
                  # Smile comment : Old version :
                  # group = group.value(item)
                  ################
                  # Smile specific : + with_children
                  with_children = nil
                  if Query.respond_to?('with_children_provided?') && Query.with_children_provided?
                    with_children = query.with_children
                    group = column.group_value(item, with_children)
                  else
                    group = column.group_value(item)
                  end

                  ################
                  # Smile specific : Fix issue if group is a model, for columns issue, root, parent
                  # Smile comment : more complicated groupable than (= true)
                  group_key = group
                  if (
                    group &&
                    (
                      (
                        column.name == :tracker &&
                        group.is_a?(Tracker)
                      ) ||
                      (
                        [:issue, :root, :parent].include?(column.name) &&
                        group.is_a?(Issue)
                      )
                    )
                  )
                    group_key = group.id
                  end

                  if first || group != previous_group
                    if group.blank? && group != false
                      group_name = "(#{l(:label_blank_value)})"
                    else
                      #---------------
                      # Smile specific : debug trace
                      logger.debug " =>prof         grouped column=#{column.name}" if debug == '2'

                      group_name = format_object(group)

                      #---------------
                      # Smile specific : debug trace
                      logger.debug " =>prof         ** group_name=#{group_name}" if debug == '3'
                    end
                    group_name ||= ""

                    #---------------
                    # Smile specific : debug trace
                    logger.debug " =>prof         group count for class #{group.class}" if debug == '2'

                    ################
                    # Smile specific : group -> group_key
                    group_count = result_count_by_group ? result_count_by_group[group_key] : nil

                    ################
                    # Smile specific #100718 Liste demandes : total F / G / D au niveau de chaque groupe
                    # Smile specific : only if query.group_additional_infos
                    if Query.respond_to?('group_additional_infos_provided?') && Query.group_additional_infos_provided?
                      if query.group_additional_infos
                        ################
                        # Smile specific : group -> group_key
                        group_totals = totals_by_group.map {|column, t| total_tag(column, t[group_key] || 0, query.hours_by_day)}.join(" ").html_safe
                      else
                        group_totals = nil
                      end
                    else
                      #--------------
                      # Smile comment : NATIVE Source Code

                      ################
                      # Smile specific : group -> group_key
                      # Smile comment totals_by_group : variable
                      group_totals = totals_by_group.map {|column, t| total_tag(column, t[group_key] || 0)}.join(" ").html_safe
                    end
                  end
                end
                yield item, group_name, group_count, group_totals
                previous_group, first = group, false
              end
              #---------------
              # Smile specific : profiling trace
              logger.debug "/=>prof     grouped_query_results -- #{format_duration(Time.now - global_start, true)}" if debug
            end

            # 4/ EXTENDED, RM 4.0.3 OK
            def column_value_hook_with_extended_queries(column, item, value, options={})
              hours_by_day  = options.has_key?(:hours_by_day)  ? options[:hours_by_day]  : nil

              result_column_value = nil

              case column.name
              ################
              # Smile specific : Id column added to TimeEntryQuery
              when :id
                if item.is_a?(TimeEntry)
                  result_column_value = value.to_s
                end
              ################
              # Smile specific #330363 Link to issue from subject column wrong
              when :subject
                if item.is_a?(TimeEntry) && item.issue_id.present?
                  item_id = item.issue_id

                  result_column_value = link_to value, issue_path(item_id, :hours_by_day => hours_by_day)
                end
              end

              if result_column_value.nil?
                column_value_hook_without_extended_queries(column, item, value, options)
              else
                result_column_value
              end
            end # def column_value_hook_with_extended_queries

            # 5/ EXTENDED, RM 4.0.0 OK  BAR + INDIC
            # Smile specific #245550 Requêtes personnalisées : filtres : indicateur du type du groupe
            def filters_options_for_select_hook_with_extended_queries(query, field, field_options)
              group = nil

              ################
              # Smile specific : hours_for_*
              if field.start_with?('spent_hours_for_')
                group = :label_budget_and_progress
              # END -- Smile specific
              #######################
              end

              if group
                group
              else
                filters_options_for_select_hook_without_extended_queries(query, field, field_options)
              end
            end
          end # base.module_eval do

          trace_prefix       = "#{' ' * (base.name.length + 19)}  --->  "
          last_postfix       = '< (SM::HO::QueriesOverride::ExtendedQueries)'

          SmileTools.trace_override "#{base.name}             alias_method  column_value_hook, :extended_queries " + last_postfix,
            true,
            :redmine_xtended_queries

          SmileTools.trace_override "#{base.name}             alias_method  filters_options_for_select_hook, :extended_queries " + last_postfix,
            true,
            :redmine_xtended_queries

          base.instance_eval do
            alias_method :column_value_hook_without_extended_queries, :column_value_hook
            alias_method :column_value_hook, :column_value_hook_with_extended_queries

            alias_method :filters_options_for_select_hook_without_extended_queries, :filters_options_for_select_hook
            alias_method :filters_options_for_select_hook, :filters_options_for_select_hook_with_extended_queries
          end

          smile_instance_methods = (base.instance_methods + base.protected_instance_methods).select{|m|
              extended_queries_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_queries', :redmine_xtended_queries)
            }

          missing_instance_methods = extended_queries_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS    instance_methods  "
          else
            trace_first_prefix = "#{base.name}         instance_methods  "
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
      end # module ExtendedQueries
    end # module QueriesOverride
  end # module Helpers
end # module Smile
