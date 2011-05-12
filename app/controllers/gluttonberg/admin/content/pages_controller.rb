# encoding: utf-8

module Gluttonberg
  module Admin
    module Content    
      class PagesController < Gluttonberg::Admin::BaseController
        drag_tree Page , :route_name => :admin_page_move 
        before_filter :find_page, :only => [:show, :edit, :delete, :update, :destroy]
        before_filter :authorize_user , :except => [:destroy , :delete]  
        before_filter :authorize_user_for_destroy , :only => [:destroy , :delete]
        
        def index
          @pages = Page.find(:all , :conditions => { :parent_id => nil } , :order => 'position' )
        end

        def show
        end
            
        def new
          @page = Page.new
          @page_localization = PageLocalization.new
          prepare_to_edit
        end
       
        def edit
          prepare_to_edit
        end
       
        def delete
          display_delete_confirmation(
            :title      => "Delete “#{@page.name}” page?",
            :url        => admin_page_path(@page),
            :return_url => admin_pages_path , 
            :warning    => "Children of this page will be also deleted."
          )
        end
         
        def create
          @page = Page.new(params["gluttonberg_page"])
          @page.user_id = current_user.id
          if @page.save
            @page.create_default_template_file
            redirect_to admin_page_url(@page)
          else
            prepare_to_edit
            render :new
          end
        end

        def update
          if @page.update_attributes(params["gluttonberg_page"]) || !@page.changed?
            redirect_to admin_page_url(@page)
          else
            prepare_to_edit
            render :edit
          end
        end

        def destroy
          if @page.destroy
            redirect_to admin_pages_path
          else            
            raise ActiveResource::ServerError
          end
        end
        
        def edit_home
          @current_home_page_id  = Page.home_page.id unless Page.home_page.blank?
          @pages = Page.all
        end
        
        def update_home
          @new_home = Page.find(params[:home])
          unless @new_home.blank?
            @new_home.update_attributes(:home => true)
          end
          redirect_to admin_generic_settings_path
        end

        private

        def prepare_to_edit
          @pages  = params[:id] ? Page.find(:all , :conditions => [ "id  != ? " , params[:id] ] ) : Page.all
          @descriptions = []
          Gluttonberg::PageDescription.all.each do |name, desc|
              @descriptions << [desc[:label], name]
          end        
        end

        def find_page
          @page = Page.find( params[:id])
          raise ActiveRecord::RecordNotFound unless @page
        end      
        
        def authorize_user
          authorize! :manage, Gluttonberg::Page
        end
        
        def authorize_user_for_destroy
          authorize! :destroy, Gluttonberg::Page
        end
        
      end
    end #content  
  end #admin
end  #gluttonberg
