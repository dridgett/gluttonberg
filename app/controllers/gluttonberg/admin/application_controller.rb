
class Gluttonberg::Admin::ApplicationController < ApplicationController
   include Gluttonberg::AdminControllerMixin
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
  
end
