require 'redmine'


Rails.logger.info 'o=>'
Rails.logger.info 'o=>Starting Extended Queries plugin for RedMine'
Rails.logger.info "o=>Application user : #{ENV['USER']}"


plugin_root = File.dirname(__FILE__)

plugin_name = :redmine_xtended_queries

require plugin_root + '/lib/not_reloaded/smile_tools'

Redmine::Plugin.register plugin_name do
  name 'Redmine e(X)tended Queries plugin'
  author 'Smile, Jérôme BATAILLE'
  author_url "mailto:Jerome BATAILLE <redmine-support@smile.fr>?subject=#{plugin_name}"
  description 'Extends the Redmine Queries and adds small Improvments'
  url "https://github.com/Smile-SA/#{plugin_name}"
  version '1.0.16'
  requires_redmine :version_or_higher => '2.6.0'

  requires_redmine_plugin :redmine_smile_base, :version_or_higher => '1.0.0'

  #Plugin home page
  settings :default => HashWithIndifferentAccess.new(
    ),
    :partial => "settings/#{plugin_name}"
end


plugin_version    = '?.?'
plugin_id         = 0
plugin_rel_root   = '.' # Root relative to application root

this_plugin = Redmine::Plugin::find(plugin_name.to_s)
if this_plugin
  plugin_version  = this_plugin.version
  plugin_id       = this_plugin.__id__
  plugin_rel_root = 'plugins/' + this_plugin.id.to_s
end


def prepend_in(dest, mixin_module)
  return if dest.include? mixin_module

  # Rails.logger.info "o=>#{dest}.prepend #{mixin_module}"
  dest.send(:prepend, mixin_module)
end

if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  rails_dispatcher = Dispatcher
else
  rails_dispatcher = Rails.configuration
end

# Executed after Rails initialization, each time the classes are reloaded
rails_dispatcher.to_prepare do
  Rails.logger.info "o=>"
  Rails.logger.info "o=>\\__ #{plugin_name} V#{plugin_version} id #{plugin_id}"

  # Id of each plugin method
  SmileTools.reset_override_count(plugin_name)

  SmileTools.trace_override "                                plugin  #{plugin_name} V#{plugin_version} id #{plugin_id}"

  ######################################
  # 3.1/ List of reloadable dependencies
  # To put here if we want recent source files reloaded
  # Outside of to_prepare, file changed => reloaded,
  # but with primary loaded source code, not the new one
  required = [
    # lib/

    # lib/controllers
    '/lib/controllers/smile_controllers_queries',
    '/lib/record_list_field_format_patch',

    # lib/helpers
    '/lib/helpers/smile_helpers_application',
    '/lib/helpers/smile_helpers_queries',

    # lib/models
    '/lib/models/smile_models_issue',
    '/lib/models/smile_models_project',
    '/lib/models/smile_models_issue_query',
    '/lib/models/smile_models_time_entry',
    '/lib/models/smile_models_time_entry_query',
    '/lib/models/smile_models_query_custom_field_column',
    '/lib/models/smile_models_query',
    '/lib/models/smile_models_query_column',
  ]

  redmine_queries_for_time_report_plugin_available = Redmine::Plugin.installed?('redmine_queries_for_time_report')
  if redmine_queries_for_time_report_plugin_available
    required << '/lib/models/smile_models_time_report_query'
  end


  ###############
  # 3.2/ Requires
  if Rails.env == "development"
    Rails.logger.debug "o=>require_dependency"
    required.each{ |d|
      Rails.logger.debug "o=>  #{plugin_rel_root + d}"
      # Reloaded each time modified
      require_dependency plugin_root + d
    }
    required = nil

    # Folders whose contents should be reloaded, NOT including sub-folders

#    ActiveSupport::Dependencies.autoload_once_paths.reject!{|x| x =~ /^#{Regexp.escape(plugin_root)}/}

    # Paths to watch when file are changed
    Rails.logger.debug 'o=>'
    Rails.logger.debug "o=>autoload_paths / watchable_dirs +="
    ['/lib/controllers', '/lib/helpers', '/lib/models'].each{|p|
      new_path = plugin_root + p
      Rails.logger.debug "o=>  #{plugin_rel_root + p}"
      ActiveSupport::Dependencies.autoload_paths << new_path
      rails_dispatcher.watchable_dirs[new_path] = [:rb]
    }
  else
    Rails.logger.debug "o=>require"
    required.each{ |p|
      # Never reloaded
      Rails.logger.debug "o=>  #{plugin_rel_root + p}"
      require plugin_root + p
    }
  end
  # END -- Manage dependencies


  #######################
  # **** 3.3.1/ Libs ****

  # Smile::{Controllers, Models, Helpers}
  # Postfix sub-modules with Override to avoid a conflic with original classes / modules
  # Specially for Models
  # They are searched first at the parent namespace
  # Example Smile::Models::Issue instead of ::Issue

  #Rails.logger.info "o=>----- LIBS"


  ##############################
  # **** 3.3.2/ Controllers ****
  Rails.logger.info "o=>----- CONTROLLERS"
  prepend_in(QueriesController, Smile::Controllers::QueriesOverride::AdvancedFilters)


  ##########################
  # **** 3.3.3/ Helpers ****
  Rails.logger.info "o=>----- HELPERS"
  # Sub-module still there if reloading
  # => Re-prepend each time
  prepend_in(ApplicationHelper, Smile::Helpers::ApplicationOverride::ExtendedQueries)
  prepend_in(QueriesHelper, Smile::Helpers::QueriesOverride::ExtendedQueries)


  #########################
  # **** 3.3.4/ Models ****
  Rails.logger.info "o=>----- MODELS"
  prepend_in(Issue, Smile::Models::IssueOverride::ExtendedQueries)
  prepend_in(Issue, Smile::Models::IssueOverride::VirtualFields)

  prepend_in(Project, Smile::Models::ProjectOverride::ExtendedQueries)

  prepend_in(Query, Smile::Models::QueryOverride::ExtendedQueries)

  unless Query.instance_methods.include?(:watcher_values)
    prepend_in(Query, Smile::Models::QueryOverride::WatcherValues)
  end

  prepend_in(IssueQuery, Smile::Models::IssueQueryOverride::ExtendedQueries)

  prepend_in(TimeEntry, Smile::Models::TimeEntryOverride::ExtendedQueries)

  prepend_in(TimeEntryQuery, Smile::Models::TimeEntryQueryOverride::ExtendedQueries)

  prepend_in(QueryCustomFieldColumn, Smile::Models::QueryCustomFieldColumnOverride::ExtendedQueries)

  if redmine_queries_for_time_report_plugin_available
    prepend_in(TimeReportQuery, Smile::Models::TimeReportQueryOverride::ExtendedQueries)
  end

  require_dependency 'query'
  unless QueryColumn.instance_methods.include?(:group_value)
    prepend_in(QueryColumn, Smile::Models::QueryColumnOverride::GroupValue)
  end


  # keep traces if classes / modules are reloaded
  SmileTools.enable_traces(false, plugin_name)

  Rails.logger.info 'o=>/--'
end # rails_dispatcher.to_prepare do
