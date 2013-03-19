MangroveValidation::Application.routes.draw do
  match "download/generate/:range" => 'download#generate', :as => 'generate_download'
  match "download/available" => 'download#available', :as => 'user_downloads'

  resources :islands

  devise_for :users
  match 'me' => 'user#me'
  match "templates/navbar/user" => 'user_geo_edits#user_navbar_links', :as => 'user_navbar_links'

  resources :user_geo_edits, :only => [:index, :show, :create] do
    collection do
      post :reallocate_geometry
    end
  end

  # Admin
  match 'admin' => "admin#index"
  match 'admin/generate' => "admin#generate"
  match 'admin/download' => "admin#download"
  match 'admin/download_users' => "admin#download_users"

  root :to => 'user_geo_edits#index'
end
