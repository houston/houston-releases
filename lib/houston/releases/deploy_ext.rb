module Houston
  module Releases
    module DeployExt
      extend ActiveSupport::Concern

      included do
        has_one :release, class_name: "Houston::Releases::Release"
      end


      def build_release
        @release ||= Houston::Releases::Release.new(
          project: project,
          environment_name: environment_name,
          commit0: project.releases.to(environment_name).most_recent_commit,
          commit1: sha,
          deploy: self)
      end

    end
  end
end
