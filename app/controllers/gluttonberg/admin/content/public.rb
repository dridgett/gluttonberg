module Gluttonberg
  module Content
    class Public < Gluttonberg::Application
      include Gluttonberg::PublicController
      
      provides :htmlf, :html, :js, :xml, :json
      
      def show
        if content_type == :htmlf
          render(:template => page_template, :layout => false, :format => :html)
        else
          render(:template => page_template, :layout => page_layout)
        end
      end
      
    end
  end
end