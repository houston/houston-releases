class DropEnvironmentIdFromReleases < ActiveRecord::Migration
  def up
    remove_column :releases, :environment_id if column_exists?(:releases, :environment_id)
  end

  def down
    add_column :releases, :environment_id, :integer unless column_exists?(:releases, :environment_id)
  end
end
