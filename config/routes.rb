Rails.application.routes.draw do |map|

  mount_at = Gluttonberg::Engine.config.mount_at

  match mount_at => 'cheese/widgets#index'

  map.resources :widgets, :only => [ :index, :show ],
                          :controller => "cheese/widgets",
                          :path_prefix => mount_at,
                          :name_prefix => "cheese_"

  match '/admin' => 'gluttonberg/admin/main#index'

  scope :module => 'Gluttonberg' do
    namespace :admin do
      #resouces :assets
    end
  end
end
