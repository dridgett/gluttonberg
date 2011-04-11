module Gluttonberg
  module Public
    class PagesController < Gluttonberg::Public::BaseController
      # TODO: In the future, pick the template to render using a custom
      # resolver. Then this can be included in all the public controllers,
      # meaning they all get locale support for free.
      # TODO: should we support fallback for default localization's template??
      def show
        template = page.view
        render :template => "pages/#{template}.#{locale.slug}.#{locale.code}"
      end
      
    end
  end
end
