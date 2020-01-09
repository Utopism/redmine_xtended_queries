if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

class FixMigrationNameOrFilters < migration
  def self.up
    execute "update schema_migrations set version='20150225140000-redmine_xtended_queries' where version='20150225140000-redmine_smile_enhancements' OR version='20150225140000-redmine_extended_queries'"
  end

  def self.down
  end
end
