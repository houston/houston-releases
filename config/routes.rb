Houston::Releases::Engine.routes.draw do

  scope "projects/:project_id" do
    get "releases", to: "releases#index", as: :releases

    scope "environments/:environment" do
      get "releases", to: "releases#index"
      post "releases", to: "releases#create"
      get "releases/new", to: "releases#new", as: :new_release
      get "releases/:id", to: "releases#show"
    end
  end

  get "releases/:id", to: "releases#show", as: :release
  get "releases/:id/edit", to: "releases#edit", as: :edit_release
  put "releases/:id", to: "releases#update"
  delete "releases/:id", to: "releases#destroy"

end
