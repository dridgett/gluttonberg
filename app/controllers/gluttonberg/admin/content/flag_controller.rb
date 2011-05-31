module Gluttonberg
  module Admin
    module Content
      class FlagController <  Gluttonberg::Admin::BaseController
      
        def index
          @flags = Flag.all
        end
        
        def moderation 
          @flag = Flag.find(params[:id])
          @flag.moderate(params[:moderation])
          redirect_to :back
        end
  
      end
    end  
  end
end