Rails.application.routes.draw do |map|

  mount_at = Gluttonberg::Engine.config.mount_at

  match '/admin' => 'gluttonberg/admin/main#index'

  scope :module => 'Gluttonberg' do
    namespace :admin do
      #resouces :assets
    end
  end
end
