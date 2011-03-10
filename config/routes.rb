Rails.application.routes.draw do |map|

  mount_at = Gluttonberg::Engine.config.mount_at

  match '/admin' => 'gluttonberg/admin/main#index'

  scope :module => 'Gluttonberg' do
    namespace :admin do
      root :to => "main#index"
      get "login" => "user_sessions#new"
      post "login" => "user_sessions#create"
      match "logout" => "user_sessions#destroy"
    end
  end
end
