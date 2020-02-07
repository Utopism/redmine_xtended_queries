require_dependency 'redmine/field_format'

module Redmine
  module FieldFormat
    Rails.logger.info "o=>adding User RecordList customized_class_names"

    # Plugin : customized_class_names Rewritten
    class RecordList
      self.customized_class_names = %w(Issue TimeEntry Version Document Project User)
    end
  end
end
