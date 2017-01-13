class DowncaseEnvironmentNamesReleases < ActiveRecord::Migration
  def up
    releases = Houston::Releases::Release.all
    pbar = ProgressBar.new("releases", releases.count)
    releases.find_each do |release|
      release.update_column :environment_name, release.environment_name.downcase
      pbar.inc
    end
    pbar.finish
  end
end
