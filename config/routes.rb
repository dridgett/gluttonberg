Rails.application.routes.draw do # |map|

  mount_at = Gluttonberg::Engine.config.mount_at

  #match '/admin' => 'gluttonberg/admin/main#index'

  scope :module => 'Gluttonberg' do
    namespace :admin do
      root :to => "main#index"
      
      scope :module => 'Content' do
        match 'content' => "main#index",      :as => :content
        resources :pages do
          resources :page_localizations
        end
      end
      #resouces :assets
      
      # Settings
      scope :module => 'Settings' do
        match 'settings' => "main#index",      :as => :settings
        resources :locales
        resources :dialects
        resources :users
        resources :generic_settings        
      end  
      
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