module Gluttonberg
  module Public 
    class PublicAssetsController <  ActionController::Base
        def show               
          @asset = Asset.first( :conditions => "id=#{params[:id]} AND  asset_hash like '#{params[:hash]}%' ")
          if @asset.blank?        
            render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/not_found'
            return 
          end
          redirect_to @asset.url
        end  
    end
  end  
end