# Smile - override methods of the Queries controller
#
# TESTED OK
#
# 1/ module AdvancedFilters
# - InstanceMethods

#require 'active_support/concern' #Rails 3

module Smile
  module Controllers
    module QueriesOverride
      module AdvancedFilters
        # extend ActiveSupport::Concern

        def self.prepended(base)
          advanced_filters_methods = [
            :filter, # 1/ REWRITTEN, TESTED RM 4.0.0 OK
          ]

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          trace_first_prefix = "#{base.name}     instance_methods  "
          trace_prefix       = "#{' ' * (base.name.length - 4)}                     --->  "
          last_postfix       = '< (SM::CO::QueriesOverride::AdvancedFilters)'

          SmileTools::trace_by_line(
            smile_instance_methods,
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_xtended_queries
          )
        end

        # 1/ REWRITTEN, RM 4.0.0 OK
        # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
        #
        # Returns the values for a query filter
        def filter
          q = query_class.new
          if params[:project_id].present?
            q.project = Project.find(params[:project_id])
          end

          ################
          # Smile specific #539595 Requête personnalisée : Filtres avancés (Demande, Parent, Racine)
          if params['advanced_filters'].present? && q.respond_to?('advanced_filters')
            q.advanced_filters = params['advanced_filters']
          end

          unless User.current.allowed_to?(q.class.view_permission, q.project, :global => true)
            raise Unauthorized
          end

          filter = q.available_filters[params[:name].to_s]
          values = filter ? filter.values : []

          render :json => values
        rescue ActiveRecord::RecordNotFound
          render_404
        end
      end # module AdvancedFilters
    end # module QueriesOverride
  end # module Controllers
end # module Smile
