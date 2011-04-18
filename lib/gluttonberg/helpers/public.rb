module Gluttonberg
  module Helpers
    # A few simple helpers to be used when rendering page templates.
    module Public
      # A simple helper which loops through a heirarchy of pages and produces a
      # set of nested lists with links to each page.
      def navigation_tree(pages, opts = {})        
        content = ""
        pages.each do |page|
          li_opts = {:id => page.slug + "Nav"}
          li_opts[:class] = "current" if page == @page
          li_content = content_tag(:a, page.nav_label, :href => page_url(page , opts)).html_safe
          children = page.children#_with_localization(:dialect => params[:dialect], :locale => params[:locale])
          li_content << navigation_tree(children , opts).html_safe unless children.blank?
          content << content_tag(:li, li_content, li_opts).html_safe
        end
        content_tag(:ul, content.html_safe, opts).html_safe
      end

      # TODO FIXME
      # Returns the URL with any locale/dialect prefix it needs
      def page_url(path_or_page , opts = {})
        path = path_or_page.is_a?(String) ? path_or_page : path_or_page.path
        #::Gluttonberg::Router.localized_url(path, params)
        "/#{opts[:slug]}/#{path}"
      end
      
      # Returns the code for google analytics
      def google_analytics
        code = Rails.configuration.gluttonberg[:google_analytics]
        output = ""
        unless code.blank?
          output += "<script type='text/javascript'>\n"
          output += "//<![CDATA[\n"
          output += "var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\n"
          output += "document.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n"
          output += "//]]>\n"
          output += "</script>\n"
          output += "<script type='text/javascript'>\n"
          output += "//<![CDATA[\n"
          output += "try {\n"
          output += "var pageTracker = _gat._getTracker(\"#{code}\");\n"
          output += "pageTracker._trackPageview();\n"
          output += "} catch(err) {}\n"
          output += "//]]>\n"
          output += "</script>\n"
        end  
        output.html_safe
      end  
    end # Public
  end # Helpers
end # Gluttonberg
