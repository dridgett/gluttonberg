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
    
    attr_accessor :page, :dialect, :locale, :path, :page_template, :page_layout
    #TODO template directory 
    ######self._template_roots << [Gluttonberg::Templates.root, :_template_location]
    before_filter :store_models_and_templates
    before_filter :find_pages
    before_filter :set_locale
    
    
  protected
  


      # Stores the details for the current locale in a thread local.
      def set_locale
        Thread.current[:locale] = {:locale => params[:locale], :dialect => params[:dialect]}
      end

      # Find all the current pages and store them in an ivar. This is done as a 
      # convenience, so all public pages will automatically have a @pages collection.
      def find_pages
        @pages = Page.all_with_localization(:parent_id => nil, :dialect => params[:dialect], :locale => params[:locale], :order => [:position.asc])
      end

      # Extracts various values set in the params by the router and puts them into
      # ivars, which are a little nicer to access.
      def store_models_and_templates
        @dialect  = params[:dialect]
        @locale   = params[:locale]
        @page     = params[:page]
        # Store the templates
        templates       = @page.template_paths(:dialect => params[:dialect], :locale => params[:locale])
        @page_template  = "pages/" + templates[:page] if templates[:page]
        @page_layout    = "#{templates[:layout]}.#{content_type}" if templates[:layout]
      end

end