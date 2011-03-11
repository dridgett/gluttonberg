module Gluttonberg
  module Admin
    module AssetLibrary
      class CollectionsController < Gluttonberg::Admin::ApplicationController
        
            def index
              @collections = AssetCollection.all
            end
  
            def new
              @collection = AssetCollection.new
            end
  
            def edit
              # if asset collection not found stop the execution of the action and render not found error
              return unless find_collection
            end

  
            # if u pass filter param then it will bring filtered assets inside collection  
            def show     
              # if asset collection not found stop the execution of the action and render not found error
              return unless find_collection
        
              @category_filter = ( params[:filter].blank? ? "all" : params[:filter] )
              opts = {:order => get_order , :per_page => 18 , :page => params[:page]}
              if @category_filter != "all"
                category = AssetCategory.find(:first , :conditions => { :name => @category_filter })
                opts[:conditions] = {:asset_type_id => category.asset_type_ids }   unless category.blank? || category.asset_type_ids.blank?
              end
        
              @assets = @collection.assets.paginate( opts )                        
            end
  
        
            def create
              @collection = AssetCollection.new(params[:collection])
              if @collection.save
                flash[:notice] = "Collection created successfully!"
                redirect_to admin_assets_url # library home page
              else
                render :new
              end
            end
  
            def update
              # if asset collection not found stop the execution of the action and render not found error
              return unless find_collection
        
              if @collection.update_attributes(params[:collection])
                flash[:notice] = "Collection updated successfully!"
                redirect_to admin_assets_url
              else
                flash[:error] = "Collection updatation failed!"
                render :new
              end
            end
  
            def destroy
              # if asset collection not found stop the execution of the action and render not found error
              return unless find_collection
        
              @collection.destroy
              flash[:notice] = "Collection destroyed successfully!"
              redirect_to admin_assets_url
            end
  
            private
  
            def find_collection
              @collection = AssetCollection.find( :first , :conditions => [" id = ? " , params[:id] ] )
        
              if @collection.blank?
                render :template => '/layouts/not_found', :status => 404 , :locals => { :message => "The asset collection you are looking for is not exist."}
                return false
              end         
              true
            end # find_collection
      

      end # class
    end #asset_library
  end #admin
end #gb    
