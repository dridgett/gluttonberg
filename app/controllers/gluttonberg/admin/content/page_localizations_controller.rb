module Gluttonberg
  module Admin
    module Content
      class PageLocalizationsController < Gluttonberg::Admin::BaseController
     
      
        before_filter :find_localization, :exclude => [:index, :new, :create]

        def index
          @page_localizations = PageLocalization.all
        end

        def new
          @page_localization = PageLocalization.new
          @page = Page.find(params[:page_id])
        end

        def edit
          @page_localization.navigation_label = @page_localization.page.navigation_label if @page_localization.navigation_label.blank?
          @page_localization.slug = @page_localization.page.slug  if @page_localization.slug.blank?
          @page_localization.save!        
        end

        def create
          @page_localization.page = Page.get_for_user(session.user , params[:page_id])
          if @page_localization.save
            redirect_to admin_page_path(params[:page_id])
          else
            render :new
          end
        end

        def update
          if @page_localization.update_attributes(params["gluttonberg_page_localization"]) || !@page_localization.changed?
            puts "---------------------saved"
            redirect_to admin_page_path(params[:page_id])
          else
            puts "---------------------update failed"
            render :edit
          end
        end

        def destroy
          if @page_localization.destroy
            redirect slice_url(:page_localization)
          else
            raise BadRequest
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
