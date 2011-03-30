module Gluttonberg
  module Public 
    class PublicAssetsController <  ActionController::Base
        def show               
          @asset = Asset.first( :conditions => "id=#{params[:id]} AND  asset_hash like '#{params[:hash]}%' ")
          if @asset.blank?        
            render :template => '/layouts/not_found', :status => 404 , :locals => { :message => "The asset you are looking for is not exist."}
            return 
          end
          redirect_to @asset.url
        end  
    end
  end  
end