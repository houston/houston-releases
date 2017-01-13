require "houston/releases/commit_ext"
require "houston/releases/deploy_ext"
require "houston/releases/project_ext"

module Houston
  module Releases
    class Railtie < ::Rails::Railtie

      # The block you pass to this method will run for every request
      # in development mode, but only once in production.
      config.to_prepare do
        ::Commit.send(:include, Houston::Releases::CommitExt)
        ::Deploy.send(:include, Houston::Releases::DeployExt)
        ::Project.send(:include, Houston::Releases::ProjectExt)
      end

    end
  end
end
