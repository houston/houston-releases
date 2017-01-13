module Houston
  module Releases
    module CommitExt
      extend ActiveSupport::Concern

      included do
        has_and_belongs_to_many :releases, class_name: "Houston::Releases::Release"
      end

      module ClassMethods
        def released
          commits_releases = Arel::Table.new("commits_releases")
          where(arel_table[:id].in(commits_releases.project(:commit_id)))
        end
      end

    end
  end
end
