module Gluttonberg
  # The Router module is used to declare the routes in Gluttonberg — of which 
  # there is a heap — and also provides helpers for setting the locale and
  # dialect for each incoming request.
  #
  # It does this via a defer_to block. This block also finds the matching page
  # which it injects into the params. In the case where it finds a page that
  # is defined as a rewrite, it will do that. A rewrite that is.
  module Router
    
    
    # Set up the many and various routes for Gluttonberg
    def self.setup(scope)
      
      # Login/Logout
      scope.match("/login", :method => :get ).to(:controller => "/exceptions", :action => "unauthenticated").name(:login)
      scope.match("/login", :method => :put ).to(:controller => "sessions", :action => "update").name(:perform_login)
      scope.match("/logout").to(:controller => "sessions", :action => "destroy").name(:logout)
      scope.match("/forgot_password", :method => :get).to(:controller => "users", :action => "forgot_password").name(:forgot_password)
      scope.match("/reset_password", :method => :put).to(:controller => "users", :action => "reset").name(:reset_password)
      
      # The admin dashboard
      scope.match("/").to(:controller => "main").name(:admin_root)
      
      scope.identify DataMapper::Resource => :id do |s|
        # Controllers in the content module
        s.match("/content").to(:controller => "content/main").name(:content)
        s.match("/content") do |c|
          c.resources(:pages, :controller => "content/pages") do |p|
            p.resources(:localizations, :controller => "content/page_localizations")
          end
          c.match("/pages/move(.:format)").to(:controller => "content/pages", :action => "move_node").name(:page_move)
        end
        
        # Asset Library
        s.match("/library").to(:controller => "library/main").name(:library)
        s.match("/library") do |a|
          a.match("/assets").to(:controller => "library/assets") do |as|
            as.match("/new_browser").to(:action => "new_browser").name(:new_browser)
            as.match("/browser").to(:action => "browser").name(:asset_browser)
            as.match("/browse/:category(/by-:order)(/:page)(.:format)", :category => /[a-zA-Z]/, :order => /[a-zA-Z]/, :page => /\d+/).
              to(:action => "category").name(:asset_category)
          end
          a.resources(:assets, :controller => "library/assets")
          a.resources(:collections, :controller => "library/collections")          
          a.match("/collections/:id/add_asset").to(:controller => "library/collections", :action => "add_asset").name(:add_asset_to_collection)
          a.match("/collections/:id(/by-:order)(/:page)(.:format)").to(:controller => "library/collections", :action => "show").name(:collection_show)
        end
      
        # Settings
        s.match("/settings").to(:controller => "settings/main").name(:settings)
        s.match("/settings") do |se|
          se.resources(:locales, :controller => "settings/locales")
          se.resources(:dialects, :controller => "settings/dialects")
          se.resources(:users, :controller => "settings/users")
          se.resources(:generic_settings, :controller => "settings/generic_settings")
        end
        
        # Help
        s.match("/help/:module_and_controller/:page", :module_and_controller => %r{\S+}).to(:controller => "help", :action => "show").name(:help)
        
        s.gluttonberg_public_routes(:prefix => "public") if Gluttonberg.standalone?
      end
    end
    
    # The huge and scary defer_to block. This block has a few different 
    # responsibilities.
    #
    # * Find the locale and dialect records, including falling back to defaults
    # * Find the matching page:
    #     - Full match for regular pages, but if that fails
    #     - Partial match triggering a rewrite
    # * Check for redirects
    # * Store the original path in params, since it may be rewritten later
    PUBLIC_DEFER_PROC = lambda do |request, params|
      
      @asset = Asset.first(:id=>params[:id] , :asset_hash.like => params[:hash] + "%")  unless params[:hash].blank?
      unless @asset.blank?        
        #redirect "http://#{request.host}#{@asset.url}"
      else
        params[:full_path] = "" unless params[:full_path]
        additional_params, conditions = Gluttonberg::Router.localization_details(params)
        # Stash the locale details in a thread local variable
        Thread.current[:locale] = {:locale => additional_params[:locale], :dialect => additional_params[:dialect]}
        page = Gluttonberg::Page.first_with_localization(conditions.merge(:path => params[:full_path]))
        if page
          case page.description[:behaviour]
            when :rewrite
              Gluttonberg::Router.rewrite(page, params[:full_path], request, params, additional_params)
            when :redirect
              destination = page.description.redirect_url(page, params)
              {:controller => "gluttonberg/redirect", :action => "to", :redirect_url => destination}
            else
              {
                :controller => params[:controller], 
                :action     => params[:action], 
                :page       => page, 
                :format     => params[:format]
              }.merge!(additional_params)
          end
        else
          # TODO: The string concatenation here is Sqlite specific, we need to 
          # handle it differently per adapter.
          names = PageDescription.names_for(:rewrite)
          component_conditions = conditions.merge(
            "page.description_name" => names,
            :conditions             => ["? LIKE (path || '%')", params[:full_path]], 
            :order                  => [:path.asc]
          )
          page = Gluttonberg::Page.first_with_localization(component_conditions)
          if page
            Gluttonberg::Router.rewrite(page, params[:full_path], request, params, additional_params)
          else
            raise Merb::ControllerExceptions::NotFound
          end
        end
      end  
    end
    
    # This is a helper method used to find a matching locale and dialect based on 
    # entries in the params. It also builds SQL conditions that can be used to 
    # find matching pages — or any other records which use the dialect/locale.
    #
    # It returns the locale/dialect in a hash and a hash of conditions to be 
    # used in queries.
    def self.localization_details(params)
      # check to see if we're localized, translated etc, then build the 
      # conditions and the additional params with the locale/dialect stuffed
      # into them. Also should include the full_path
      additional_params = {}
      conditions = {}
      # Get the locale, falling back to a default
      opts = if Gluttonberg.localized?
        {:slug => params[:locale]}
      else
        {:default => true}
      end
      locale = Gluttonberg::Locale.first(opts)
      raise Merb::ControllerExceptions::NotFound unless locale
      additional_params[:locale] = locale
      conditions[:locale_id] = locale.id
      # Get the dialect, falling back to a default
      dialect = if Gluttonberg.translated?
        cascade_to_dialect(
          Gluttonberg::Dialect.all(:conditions => ["? LIKE code || '%'", params[:dialect]]),
          params[:dialect]
        )
      else
        Gluttonberg::Dialect.first(:default => true)
      end
      raise Merb::ControllerExceptions::NotFound unless dialect
      additional_params[:dialect] = dialect
      conditions[:dialect_id] = dialect.id
      
      additional_params[:original_path] = params[:full_path]
      # If it's all good just return them both
      [additional_params, conditions]
    end
    
    # Loops through a collection of dialect records and returns the first, 
    # closest match.
    #
    # For example, if you pass in "en-au", it will first check for an exact
    # match, if that is missing, it’ll next try "en".
    def self.cascade_to_dialect(dialects, requested_dialect)
      # If the dialects are empty, just return the default straight away.
      #
      # If we have dialects in our DB, let's try to find a match. If we don't
      # have any matches, lets reduce the request lang and recurse until we find 
      # a match or need to return the default.
      if dialects.nil?
        dialects.first(:default => true)
      else
        match = dialects.pluck {|d| d.code == requested_dialect}
        if match
          match
        else
          index = requested_dialect.rindex("-")
          if index
            cascade_to_dialect(dialects, requested_dialect[0, index])
          else
            dialects.first(:default => true)
          end
        end
      end
    end
    
    # Rewrite the incoming path based on the route taken from the matching 
    # page’s description. The request object is then passed through the router
    # again to generate the params needed to route to the correct controller.
    def self.rewrite(page, original_path, request, params, additional_params)
      additional_params[:page] = page
      additional_params[:format] = params[:format]
      rewrite_path = Merb::Router.url(page.description.rewrite_route)
      request.env["REQUEST_PATH"] = original_path.gsub(page.current_localization.path, rewrite_path)
      new_params = Merb::Router.match(request)[1]
      new_params.merge(additional_params)
    end
    
    # A helper which adds the localization details to the start of the path 
    # passed in.
    #
    #   Gluttonberg::Router.localized_url("foo") # => "/au/en/foo"
    #
    def self.localized_url(path, params)
      opts, named_route = if path == "/"
        [{}, :root]
      else
        [{:full_path => path}, :page]
      end
      if ::Gluttonberg.localized_and_translated?
        opts.merge!(:locale => coerce_locale(params), :dialect => coerce_dialect(params))
      elsif ::Gluttonberg.localized?
        opts.merge!(:locale => coerce_locale(params))
      elsif ::Gluttonberg.translated?
        opts.merge!(:dialect => coerce_dialect(params))
      end
      Merb::Router.url((Gluttonberg.standalone? ? :"gluttonberg_public_#{named_route}" : :"public_#{named_route}"), opts)
    end
    
    # Get the string representation of a locale from the params.
    def self.coerce_locale(params)
      if params[:locale].is_a? String
        params[:locale]
      else
        params[:locale].slug
      end
    end
    
    # Get the string representation of a dialect from the params.
    def self.coerce_dialect(params)
      if params[:dialect].is_a? String
        params[:dialect]
      else
        params[:dialect].code
      end
    end
    
    # Merb’s router extensions are used to add declarations that can be used 
    # inside the router configuration.
    Merb::Router.extensions do      
      
      # This declaration sets up the routes that allow Gluttoberg to handle 
      # requests from the public side of an app. Most of this logic is just
      # figuring out what the components of the URL should look like — should
      # it have a locale prefix? Then it declares a route, which defers to our
      # PUBLIC_DEFER_PROC.
      def gluttonberg_public_routes(opts = {})
        Merb.logger.info("Adding Gluttonberg's public routes")

        # Only generate DragTree routes if we are NOT running as a standalone slice
        # users of DragTree within the slice need to explicitly set the route!
        # these need to be before the more generic routes added below
        Gluttonberg::DragTree::RouteHelpers.build_drag_tree_routes(self) unless Gluttonberg.standalone?

        # See if we need to add the prefix
        path = opts[:prefix] ? "/#{opts[:prefix]}/" : "/"
        # Check to see if this is localized or translated and if either need to
        # be added as a URL prefix. For now we just assume it's going into the
        # URL.
        if Gluttonberg.localized_and_translated?
          path << ":locale/:dialect"
        elsif Gluttonberg.localized?
          path << ":locale"
        elsif Gluttonberg.translated?
          path << ":dialect"
        end
        
        #for public asset path via controller
        controller = Gluttonberg.standalone? ? "library/public_assets" : "gluttonberg/library/public_assets"
        match("/asset/:hash/:id").to(:controller => controller, :action => "show").name(:public_asset)
        
        # Build the full path, which includes the format. This needs to account
        # for the simple case where we match from "/"
        full_path = if Gluttonberg.localized? || Gluttonberg.translated?
          "/:full_path(.:format)"
        else
          ":full_path(.:format)"
        end

        controller = Gluttonberg.standalone? ? "content/public" : "gluttonberg/content/public"
        # Set up the defer to block
        match(path + full_path, :full_path => /[a-z0-9\-_\/]+/).defer_to(
          {:controller => controller, :action => "show"}, 
          &Gluttonberg::Router::PUBLIC_DEFER_PROC
        ).name(:public_page)
        # Filthy hack to match against the root, since the URL won't 
        # regenerate with optional parameters — :full_path
        match(path).defer_to({:controller => controller, :action => "show"}, &Gluttonberg::Router::PUBLIC_DEFER_PROC).name(:public_root)              
      end
    end
  end
end