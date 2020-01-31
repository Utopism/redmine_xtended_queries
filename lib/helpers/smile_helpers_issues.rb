# Smile - issues_helper enhancement
# module Smile::Helpers::IssuesOverride
#
# - 1/ module ::BetterIssueWithChildrenDeletionWarning
#      #994 B&A hours informations
#      #111509 Interface - Différenciations entre un ticket ouvert et un ticket clôturé


module Smile
  module Helpers
    module IssuesOverride
      #*******
      # 1/ BetterIssueWithChildrenDeletionWarning
      module BetterIssueWithChildrenDeletionWarning
        def self.prepended(base)
          better_warning_instance_methods = [
            :issues_destroy_confirmation_message,        # 1/ REWRITTEN RM V4.0.3 OK
          ]

          # Methods dynamically added to the Helper module
          base.module_eval do
            # 1/ REWRITTEN, RM 4.0.3 OK
            def issues_destroy_confirmation_message(issues)
              issues = [issues] unless issues.is_a?(Array)
              message = l(:text_issues_destroy_confirmation)

              descendant_count = issues_descendant_count(issues)
              if descendant_count > 0
                message << "\n" + '<font color="red">' + l(:text_issues_destroy_descendants_confirmation, :count => descendant_count) + '</font>'
              end
              message
            end
          end # base.module_eval do


          trace_prefix       = "#{' ' * (base.name.length + 20)}  --->  "
          last_postfix       = '< (SM::HO::IssuesOverride::BetterIssueWithChildrenDeletionWarning)'

          smile_instance_methods = base.instance_methods.select{|m|
              better_warning_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_issues', :redmine_xtended_queries)
            }

          missing_instance_methods = better_warning_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS     instance_methods  "
          else
            trace_first_prefix = "#{base.name}          instance_methods  "
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
        end # def self.prepended
      end # module BetterIssueWithChildrenDeletionWarning
    end # module IssuesOverride
  end # module Helpers
end # module Smile
