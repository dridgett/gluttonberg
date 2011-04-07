module Gluttonberg
  module Public
    class PagesController < ActionController::Base
      layout "public"
      before_filter :retrieve_page_and_locale

      attr_accessor :page, :locale

      # TODO: In the future, pick the template to render using a custom
      # resolver. Then this can be included in all the public controllers,
      # meaning they all get locale support for free.
      # TODO: should we support fallback for default localization's template??
      def show
        template = page.view
        render :template => "pages/#{template}.#{locale.slug}.#{locale.code}"
      end

      private

      def retrieve_page_and_locale
        @page = env['gluttonberg.page']
        @locale = env['gluttonberg.locale']
      end
    end
  end
end
