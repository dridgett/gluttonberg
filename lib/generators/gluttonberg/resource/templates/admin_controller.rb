module Admin
  class <%= plural_class_name %>Controller < Gluttonberg::Admin::BaseController
    before_filter :authorize_user , :except => [:destroy , :delete]  
    before_filter :authorize_user_for_destroy , :only => [:destroy , :delete]
    
    def index
      @<%= plural_name %> = <%= class_name %>.all
    end
  
    def show
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
    end
  
    def new
      @<%= singular_name %> = <%= class_name %>.new
    end
  
    def edit
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
    end
  
    def create
      @<%= singular_name %> = <%= class_name %>.create(params[:<%= singular_name %>])
      if @<%= singular_name %>.save
        redirect_to admin_<%= plural_name %>_path
      else
        render :edit
      end  
    end
  
    def update
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = "Record updated."
        redirect_to admin_<%= plural_name %>_path
      else
        flash[:error] = "There was an error updating the record."
        render :edit
      end
    end
  
    def delete
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
      display_delete_confirmation(
        :title      => "Delete <%= class_name %> '#{@<%= singular_name %>.id}'?",
        :url        => admin_<%= singular_name %>_path(@<%= singular_name %>),
        :return_url => admin_<%= plural_name %>_path, 
        :warning    => ""
      )
    end
  
    def destroy
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
      if @<%= singular_name %>.delete
        flash[:notice] = "Record deleted."
        redirect_to admin_<%= plural_name %>_path
      else
        flash[:error] = "There was an error deleting the record."
        redirect_to admin_<%= plural_name %>_path
      end
    end
    
    private 
      
      def authorize_user
        authorize! :manage, <%= class_name %>
      end

      def authorize_user_for_destroy
        authorize! :destroy, <%= class_name %>
      end

  end
end