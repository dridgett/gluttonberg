module Gluttonberg
  module Admin
    module Content
      class PageLocalizationsController < Gluttonberg::Admin::BaseController
        before_filter :find_localization, :exclude => [:index, :new, :create]
        
        def edit
          @page_localization.navigation_label = @page_localization.page.navigation_label if @page_localization.navigation_label.blank?
          @page_localization.slug = @page_localization.page.slug  if @page_localization.slug.blank?
          @page_localization.save!        
        end

        def update
          if @page_localization.update_attributes(params["gluttonberg_page_localization"]) || !@page_localization.changed?            
            redirect_to admin_page_path(params[:page_id])
          else
            render :edit
          end
        end

        private

        def find_localization
          @page_localization = PageLocalization.find(params[:id])
          raise NotFound unless @page_localization
        end
      end #class  
    end
  end  
end
