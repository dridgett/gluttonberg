class Gluttonberg::Admin::Membership::BaseController < Gluttonberg::Admin::BaseController
  before_filter :is_members_enabled
  
  protected
    def is_members_enabled 
      unless Gluttonberg::Member.enable_members == true
        raise CanCan::AccessDenied
      end  
    end  
    
end  