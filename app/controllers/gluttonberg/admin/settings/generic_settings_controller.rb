module Gluttonberg
  module  Admin
    module Settings
      class GenericSettingsController < Gluttonberg::Admin::BaseController
 
    
        def index
          @settings = Setting.find(:all , :order => "row asc")
        end
              
        def new
          @setting = Setting.new
        end
    
        def edit
          @setting = Setting.find(params[:id])
          raise NotFound unless @setting
        end
    
        def create
          @setting = Setting.new(params["gluttonberg_setting"])
          count = Setting.all.length
          @setting.row = count + 1
          if @setting.save!
            redirect_to admin_generic_settings_path
          else
            message[:error] = "Setting failed to be created"
            render :new
          end
        end
    
        def update
          @setting = Setting.find(params[:id])
          raise NotFound unless @setting
          if @setting.update_attributes(params["gluttonberg_setting"])
            redirect_to admin_generic_settings_path
          else
            render :edit
          end
        end

        def destroy
          @setting = Setting.find(params[:id])
          raise NotFound unless @setting
          if @setting.destroy
            redirect_to admin_generic_settings_path
          else
            raise InternalServerError
          end
        end
    
      end # GenericSettings
    end # Settings
  end #admin  
end # Gluttonberg