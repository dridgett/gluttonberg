class Gluttonberg::Admin::Membership::BaseController < Gluttonberg::Admin::BaseController
  before_filter :is_members_enabled
  
  protected
    def is_members_enabled 
      unless Rails.configuration.enable_members == true
        raise ActiveRecord::RecordNotFound
      end  
    end  
    
end  