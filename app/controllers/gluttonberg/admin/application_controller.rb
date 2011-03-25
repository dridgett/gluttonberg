class Gluttonberg::Admin::BaseController < ActionController::Base
   #include Gluttonberg::AdminControllerMixin
   helper_method :current_user_session, :current_user
   before_filter :require_user
   
   layout 'gluttonberg'

   unloadable
  
  
  protected 
    # this method is used by sorter on asset listing by category and by collection
    def get_order
      case params[:order]
      when 'name'
        "gb_assets.name"
      when 'date-updated'
        "updated_at desc"
      else
        "created_at desc"
      end
    end
    
    
    
    # Use the included hook to set up the layout and install the authentication
    #def self.included(klass)
      #klass.class_eval do
        #self._template_roots << [Gluttonberg.root / "app" / "views", :_template_location]
        #layout("gluttonberg")
        #before :ensure_authenticated
      #end
    #end
    
        
    
    # This is to be used in a before filter.
    def set_locale
      Thread.current[:locale] = localization_ids
    end
    
    # This is to be called from within a controller — i.e. the delete action — 
    # and it will display a dialog which allows users to either confirm 
    # deleting a record or cancelling the action.
    def display_delete_confirmation(opts)
      @options = opts      
      @do_not_delete = (@options[:do_not_delete].blank?)? false : @options[:do_not_delete]
      
      unless @do_not_delete
        @options[:title]    ||= "Delete Record?"
        @options[:message]  ||= "If you delete this record, it will be gone permanently. There is no undo."
      else
        @options[:title]    = "Sorry you cannot delete this record!"
        @options[:message]  ||= "It is been used by some other records."
      end  
      render :template => "shared/delete", :layout => false
    end
    
    # This is to be called from within a controller — i.e. the publish/unpublish action — 
    # and it will display a dialog which allows users to either confirm 
    # publish/unpublish a record or cancelling the action.
    def display_generic_confirmation(name , opts)
      @options = opts
      @do_not_do = (@options[:do_not_do].blank?)? false : @options[:do_not_do]
      @name = name
      
      unless @do_not_do
        @options[:title]    ||= "#{@name.capitalize} Record?"
        @options[:message]  ||= "If you #{@name.downcase} this record, it will be #{@name}"
      else
        @options[:title]    = "Sorry you cannot #{@name.capitalize} this record!"
        @options[:message]  ||= "It's parent record is not #{@name.capitalize}."
      end  
      render :template => "shared/generic", :layout => false
      
    end
    
    # A helper for finding shortcutting the steps in finding a model ensuring
    # it has a localization and raising a NotFound if it’s missing.
    def with_localization(model, id)
      result = model.first_with_localization(localization_ids.merge(:id => id))
      raise NotFound unless result
      result.ensure_localization!
      result
    end
    
    # Returns a hash with the locale and dialect ids extracted from the params
    # or where they're missing, it will grab the defaults.
    def localization_ids
      @localization_opts ||= begin
        if params[:localization]
          ids = params[:localization].split("-")
          {:locale => ids[0], :dialect => ids[1]}
        else
          dialect = Gluttonberg::Dialect.first(:default => true)
          locale = Gluttonberg::Locale.first(:default => true)
          # Inject the ids into the params so our form fields behave
          params[:localization] = "#{locale.id}-#{dialect.id}"
          {:locale => locale.id, :dialect => dialect.id}
        end
      end
    end
    
    # Below is all the required methods for authentication
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to admin_login_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
  
end
