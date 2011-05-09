# encoding: utf-8

module Gluttonberg
  module Admin
    module AssetLibrary
      class CollectionsController < Gluttonberg::Admin::BaseController
        before_filter :find_collection  , :only => [:delete , :edit  , :show , :update , :destroy]  
        
        def index
          @collections = AssetCollection.all
        end

        def new
          @collection = AssetCollection.new
        end

        def edit              
        end

        # if u pass filter param then it will bring filtered assets inside collection  
        def show     
          @category_filter = ( params[:filter].blank? ? "all" : params[:filter] )
          opts = {
              :order => get_order , 
              :per_page => Rails.configuration.gluttonberg[:number_of_per_page_items] , 
              :page => params[:page]
          }
          if @category_filter != "all"
            category = AssetCategory.find(:first , :conditions => { :name => @category_filter })
            opts[:conditions] = {:asset_type_id => category.asset_type_ids }   unless category.blank? || category.asset_type_ids.blank?
          end
  
          @assets = @collection.assets.paginate( opts )                        
        end

  
        def create
          @collection = AssetCollection.new(params[:collection].merge(:user_id => current_user.id))
          if @collection.save
            flash[:notice] = "Collection created successfully!"
            # library home page
            redirect_to admin_assets_url 
          else
            render :new
          end
        end

        def update
          if @collection.update_attributes(params[:collection])
            flash[:notice] = "Collection updated successfully!"
            redirect_to admin_assets_url
          else
            flash[:error] = "Collection updatation failed!"
            render :new
          end
        end
      
         def delete
            display_delete_confirmation(
              :title      => "Delete “#{@collection.name}” asset collection?",
              :url        => admin_collection_path(@collection),
              :return_url => admin_collections_path 
            )  
          end

        def destroy
          if @collection.destroy
            flash[:notice] = "Collection destroyed successfully!"
            redirect_to admin_assets_url
          else
            raise ActiveResource::ServerError
          end  
        end

        private

        def find_collection
          @collection = AssetCollection.find( :first , :conditions => [" id = ? " , params[:id] ] )        
          raise ActiveRecord::RecordNotFound  if @collection.blank?              
        end # find_collection

      end # class
    end #asset_library
  end #admin
end #gb    
