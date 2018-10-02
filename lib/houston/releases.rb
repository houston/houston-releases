require "houston/releases/engine"
require "houston/releases/configuration"

module Houston
  module Releases
    extend self

    def dependencies
      [ :commits ]
    end

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
  register_events {{
    "release:create" => params("release").desc("A new release was created")
  }}


  # Add a link to feature that can be turned on for projects
  Houston.add_project_feature :releases do
    name "Releases"
    path { |project| Houston::Releases::Engine.routes.url_helpers.releases_path(project) }
    ability { |ability, project| ability.can?(:read, project.releases.build) }

    field "releases.environments" do
      name "Environments"
      html do |f|
        if @project.environments.none?
          ""
        else
          html = <<-HTML
          <p class="instructions">
            Generate release notes for these environments:
          </p>
          HTML
          @project.environments.each do |environment|
            id = :"releases.ignore.#{environment}"
            value = f.object.public_send(id) || "0"
            html << f.label(id, class: "checkbox") do
              f.check_box(id, {checked: value == "0"}, "0", "1") +
              " #{environment.titleize}"
            end
          end
          html
        end
      end
    end
  end

end
