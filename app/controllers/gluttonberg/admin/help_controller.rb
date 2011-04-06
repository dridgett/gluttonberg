module Gluttonberg
  module Admin
    class HelpController <  Gluttonberg::Admin::BaseController
      layout "help"
    
      def show
        template = Help.path_to_template(:controller => params[:module_and_controller], :page => params[:page])
        opts = {:template => template}
        opts[:layout] = "ajax" if request.xhr?
        render(opts)
      end
      
    end
  end  
end