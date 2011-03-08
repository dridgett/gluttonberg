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
          li_content = tag(:a, page.nav_label, :href => page_url(page))
          children = page.children_with_localization(:dialect => params[:dialect], :locale => params[:locale])
          li_content << navigation_tree(children) unless children.empty?
          content << "\n\t#{tag(:li, li_content, li_opts)}"
        end
        tag(:ul, "#{content}\n", opts)
      end

      # Returns the URL with any locale/dialect prefix it needs
      def page_url(path_or_page)
        path = path_or_page.is_a?(String) ? path_or_page : path_or_page.path
        ::Gluttonberg::Router.localized_url(path, params)
      end
      
      # Returns the code for google analytics
      def google_analytics
        code = Merb::Slices::config[:gluttonberg][:google_analytics]
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
        output
      end  
    end # Public
  end # Helpers
end # Gluttonberg
