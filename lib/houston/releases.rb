require "houston/releases/engine"
require "houston/releases/configuration"

module Houston
  module Releases
    extend self

    def config(&block)
      @configuration ||= Releases::Configuration.new
      @configuration.instance_eval(&block) if block_given?
      @configuration
    end

  end


  # Extension Points
  # ===========================================================================
  #
  # Read more about extending Houston at:
  # https://github.com/houston/houston-core/wiki/Modules


  # Register events that will be raised by this module
  #
  #    register_events {{
  #      "releases:create" => params("releases").desc("Releases was created"),
  #      "releases:update" => params("releases").desc("Releases was updated")
  #    }}


  # Add a link to Houston's global navigation
  #
  #    add_navigation_renderer :releases do
  #      name "Releases"
  #      icon "fa-thumbs-up"
  #      path { Houston::Releases::Engine.routes.url_helpers.releases_path }
  #      ability { |ability| ability.can? :read, Project }
  #    end


  # Add a link to feature that can be turned on for projects
  #
  #    add_project_feature :releases do
  #      name "Releases"
  #      icon "fa-thumbs-up"
  #      path { |project| Houston::Releases::Engine.routes.url_helpers.project_releases_path(project) }
  #      ability { |ability, project| ability.can? :read, project }
  #    end

end
