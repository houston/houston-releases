class AssociateRemainingReleases < ActiveRecord::Migration
  def up
    @invalid_shas = 0

    pbar = ProgressBar.new("releases", Houston::Releases::Release.where(commit_before_id: nil).count)
    Houston::Releases::Release.includes(:project).where(commit_before_id: nil).find_each do |release|
      pbar.inc
      next unless release.project
      next if release.project.retired?

      sha0 = release.read_attribute(:commit0)
      commit0 = find_commit(release.project, sha0)
      release.update_column :commit_before_id, commit0.id if commit0
    end
    pbar.finish

    pbar = ProgressBar.new("releases", Houston::Releases::Release.where(commit_after_id: nil).count)
    Houston::Releases::Release.includes(:project).where(commit_after_id: nil).find_each do |release|
      pbar.inc
      next unless release.project
      next if release.project.retired?

      sha1 = release.read_attribute(:commit1)
      commit1 = find_commit(release.project, sha1)
      release.update_column :commit_after_id, commit1.id if commit1
    end
    pbar.finish

    puts "\e[31;1m#{@invalid_shas}\e[0;31m invalid shas\e[0m"
    puts "\e[33;1m#{Houston::Releases::Release.where(commit_before_id: nil).count}\e[0;33m out of \e[1m#{Houston::Releases::Release.count}\e[0;33m release don't have a commit_before\e[0m"
    puts "\e[33;1m#{Houston::Releases::Release.where(commit_after_id: nil).count}\e[0;33m out of \e[1m#{Houston::Releases::Release.count}\e[0;33m release don't have a commit_after\e[0m"
  end

private

  def find_commit(project, sha)
    project.find_commit_by_sha(sha)
  rescue Houston::Adapters::VersionControl::CommitNotFound
    nil
  rescue Houston::Adapters::VersionControl::InvalidShaError
    @invalid_shas += 1
    nil
  end

end
