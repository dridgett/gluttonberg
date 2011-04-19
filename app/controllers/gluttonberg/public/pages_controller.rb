module Gluttonberg
  module Public
    class PagesController < Gluttonberg::Public::BaseController
      before_filter :retrieve_page
      
      # If localized template file exist then render that file otherwise render non-localized template
      def show
        template = page.view
        if File.exists?(File.join(Rails.root,  "app/views/pages/#{template}.#{locale.slug}.html.haml" ) )
          render :template => "pages/#{template}.#{locale.slug}"
        else
          render :template => "pages/#{template}" 
        end  
      end
      
      private 
        def retrieve_page
          @page = env['gluttonberg.page']
          raise ActiveRecord::RecordNotFound  if @page.blank?
        end
      
    end
  end
end
