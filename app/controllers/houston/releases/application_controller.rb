module Houston::Releases
  class ApplicationController < ::ApplicationController
    layout "houston/releases/application"
    helper "houston/releases/release"
  end
end
