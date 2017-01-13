class GenerateIndexOnReleases < ActiveRecord::Migration
  def change
    Houston::Releases::Release.reindex!
  end
end
