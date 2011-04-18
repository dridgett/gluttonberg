# This Class is intended to be used to integrate an arbitrary controller into
# the Gluttonberg front end. It provides access to the locale/dialect processing,
# templating, page collections for generating navigations and injects a bunch of
# other useful helpers.


class Gluttonberg::Public::BaseController < ActionController::Base
    # The included hook is used to create a bunch of class-ivars, which are used to
    # store various configuration options.
    #
    # It also installs before and after hooks that have been declared elsewhere
    # in this module.
    
    attr_accessor :page, :locale #, :path, :page_template, :page_layout    
    before_filter :retrieve_locale    
    layout "public"
        
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    rescue_from ActionController::RoutingError, :with => :not_found
    
  protected
  
      def retrieve_locale
        @locale = env['gluttonberg.locale']
      end

      # TODO Fixme
      def store_templates
        # Store the templates
        # templates       = @page.template_paths(:dialect => params[:dialect], :locale => params[:locale])
        # @page_template  = "pages/" + templates[:page] if templates[:page]
        # @page_layout    = "#{templates[:layout]}.#{content_type}" if templates[:layout]        
      end
      
      # Exception handlers
       def not_found
          render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/not_found'
        end

        # handle NotAcceptable exceptions (406)
        def not_acceptable
          render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/not_acceptable'
        end
        def internal_server_error
          render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/internal_server_error'
        end

end