module Houston
  module Releases
    class Mailer < ViewMailer
      helper ReleaseHelper

      self.stylesheets = stylesheets + %w{
        houston/releases/releases.scss
      }

      def release(release, options={})
        @release = release
        @project = release.project

        mail({
          from:     release.user,
          to:       options.fetch(:to, @release.notification_recipients),
          subject:  "#{@project.name}: new release to #{release.environment_name}",
          template: "houston/releases/mailer/new_release"
        })
      end


      def maintainer_of_deploy(maintainer, deploy)
        @project = deploy.project
        @release = deploy.build_release
        @maintainer = maintainer

        if @maintainer.respond_to?(:reset_authentication_token!)
          @maintainer.reset_authentication_token!
          @auth_token = @maintainer.authentication_token
        end

        if @release.commits.empty? && @release.can_read_commits?
          @release.load_commits!
          @release.build_changes_from_commits
        end

        mail({
          to:       @maintainer,
          subject:  "#{@project.name}: deploy to #{deploy.environment_name} complete. Click to Release!",
          template: "houston/releases/mailer/new_release"
        })
      end


    end
  end
end
