module Houston::Releases
  class ApplicationController < ::ApplicationController
    layout "houston/releases/application"
    helper Houston::Releases::ReleaseHelper
  end
end
