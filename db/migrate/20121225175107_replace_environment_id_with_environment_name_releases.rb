class ReplaceEnvironmentIdWithEnvironmentNameReleases < ActiveRecord::Migration
  RENAMES = {"dev" => "Staging", "master" => "Production"}

  class Environment < ActiveRecord::Base; end

  def up
    return if column_exists? :releases, :project_id

    add_column :releases, :project_id, :integer, null: false, default: -1
    add_column :releases, :environment_name, :string, null: false, default: "Production"
    add_index :releases, :project_id
    add_index :releases, [:project_id, :environment_name]

    Houston::Releases::Release.tap(&:reset_column_information).all.each do |release|
      if release.respond_to?(:environment_id) && (environment = Environment.find_by_id(release.environment_id))
        release.update_column(:project_id, environment.project_id)
        release.update_column(:environment_name, environment.name)
      end
    end
  end

  def down
    remove_column :releases, :project_id
    remove_column :releases, :environment_name
  end
end
