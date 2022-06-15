# Smile - application_helper enhancement
# module Smile::Helpers::ApplicationOverride
#
# * 1/ module ::ExtendedQueries
#      * format_object_with_extended_queries EXTENDED
#        Used to display custom values everywhere
#        alias_method NEEDED because call ancestor with module_eval
#        * #134828 New issues list columns (Array, IssueRelations, Watchers)
#          2013
#        * #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
#          2013


module Smile
  module Helpers
    module ApplicationOverride
      ####################
      # 1/ ExtendedQueries
      module ExtendedQueries
        def self.prepended(base)
          extended_queries_instance_methods = [
            :format_object_hook,  # 1/ New method TO TEST  V4.0.0 OK
          ]

          # Smile comment : module_eval mandatory with helpers, but no more access to rewritten methods
          # Smile comment : => use of alias method to access to ancestor version
          base.module_eval do
            # 1/ New method, RM 4.0.0 OK
            # Smile specific #134828 New issues list columns (Array, IssueRelations, Watchers)
            # Smile specific #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
            # * Options param added :
            #   * id_only(false)
            #   * links(true)
            #   * debug(false)
            #
            #
            # Helper that formats object for html or text rendering
            def format_object_hook_with_links(object, html=true, options={})
              # Smile comment : options needed only to override specific cases
              debug         = options.has_key?( :debug )        ? options[:debug]        : false
              id_only       = options.has_key?( :id_only )      ? options[:id_only]      : false
              links         = options.has_key?( :links )        ? options[:links]        : true

              # Smile comment : override specific cases
              result_format_object = case object.class.name
              when 'Issue' # OVERRIDEN V4.0.3 OK
                # Smile comment : Optimization, do not check visibility if id only
                # Smile comment : => This will NOT reveal the issue subject if issue is not visible
                # Smile specific : +links option, link_to_issue : +subject, tracker, show_status
                # columns issue, root (parent treated in columns_value)
                # Smile comment : UPSTREAM code
                # object.visible? && html ? link_to_issue(object) : "##{object.id}"
                ( (id_only || object.visible?) && html && links ) ? link_to_issue(object, :subject => !id_only, :tracker => !id_only, :show_status => !id_only) : "##{object.id}"
              when 'User'
                ################
                # Smile specific : links option
                unless links
                  object.to_s
                end
              when 'Watcher' # New
                ################
                # Smile specific : link added
                # Smile specific : links option
                (html && links) ? link_to_user(object.user) : object.to_s
              when 'Project'
                ################
                # Smile specific : links option
                unless links
                  object.to_s
                end
              when 'Float'
                ################
                # Smile specific : five decimals, remove trailing zeros
                sprintf("%.5f", object).sub(/\.?0+$/, '')
              end

              if result_format_object
                logger.debug " =>prof sha       format_object_hook_with_links queries   #{object.class} links=#{links}" if debug == '2'
              end

              result_format_object
            end
          end # base.module_eval do


          trace_prefix         = "#{' ' * (base.name.length + 15)}  --->  "
          module_name          = 'SM::HO::AppOverride::ExtendedQueries'
          last_postfix         = "< (#{module_name})"

          SmileTools.trace_override "#{base.name}         alias_method  format_object_hook, :links " + last_postfix,
            true,
            :redmine_xtended_queries

          base.instance_eval do
            alias_method :format_object_hook_without_links, :format_object_hook
            alias_method :format_object_hook, :format_object_hook_with_links
          end


          smile_instance_methods = base.instance_methods.select{|m|
              extended_queries_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin(
                  'lib/helpers/smile_helpers_application',
                  :redmine_xtended_queries
                )
            }

          missing_instance_methods = extended_queries_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MIS instance_methods  "
          else
            trace_first_prefix = "#{base.name}     instance_methods  "
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
    end # module ApplicationOverride
  end # module Helpers
end # module Smile
