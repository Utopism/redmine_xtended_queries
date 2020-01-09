if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end
class AddQueriesOrFilters < migration
  def up
    add_column :queries, :or_filters, :text
  end

  def down
    remove_column :queries, :or_filters
  end
end
