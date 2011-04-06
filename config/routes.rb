Rails.application.routes.draw do # |map|

  mount_at = Gluttonberg::Engine.config.mount_at

  #match '/admin' => 'gluttonberg/admin/main#index'

  scope :module => 'Gluttonberg' do
    namespace :admin do
      root :to => "main#index"
      
      scope :module => 'Content' do
        match 'content' => "main#index",      :as => :content
        resources :pages do
          get 'delete', :on => :member
          resources :page_localizations           
        end
        match "/pages/move(.:format)" => "pages#move_node" , :as=> :page_move
      end
      #resouces :assets
      
      # Settings
      scope :module => 'Settings' do
        match 'settings' => "main#index",      :as => :settings
        resources :locales do 
          get 'delete', :on => :member
        end
        resources :dialects do
          get 'delete', :on => :member
        end
        resources :users do
          get 'delete', :on => :member
        end
        
        resources :generic_settings do 
          get 'delete', :on => :member
        end       
      end  
      
      scope :module => 'AssetLibrary' do
        # asset library related routes
          resources :assets
          match "library" => "assets#index" , :as => :library
          match "add_assets_in_bulk"  => "assets#add_assets_in_bulk" , :as => :add_assets_in_bulk
          match "create_assets_in_bulk"  => "assets#create_assets_in_bulk" , :as => :create_assets_in_bulk
          match "browser"  => "assets#browser" , :as => :asset_browser
          match "browse/:category/page/:page"  => "assets#category" , :as => :asset_category
          match "collections/:id/page/:page"  => "collections#show" , :as => :asset_collection
          resources :collections        
      end
      
      resources :password_resets
      
      get "login" => "user_sessions#new"
      post "login" => "user_sessions#create"
      match "logout" => "user_sessions#destroy"
    end
    
    scope :module => 'Public' do
        match "/asset/:hash/:id" => "public_assets#show" , :as => :public_asset
    end
    
  end
end




# s.match("/content").to(:controller => "content/main").name(:content)
# s.match("/content") do |c|
#   c.resources(:pages, :controller => "content/pages") do |p|
#     p.resources(:localizations, :controller => "content/page_localizations")
#   end
#   c.match("/pages/move(.:format)").to(:controller => "content/pages", :action => "move_node").name(:page_move)
# end
