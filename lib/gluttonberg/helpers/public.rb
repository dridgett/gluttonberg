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
          if page.home?
            li_content = ""
          else
            if page.description && page.description.top_level_page?
              li_content = content_tag(:a, page.nav_label, :href => "#").html_safe
            else
              li_content = content_tag(:a, page.nav_label, :href => page_url(page , opts)).html_safe
            end
          end
          children = page.children
          li_content << navigation_tree(children , opts).html_safe unless children.blank?
          content << content_tag(:li, li_content.html_safe, li_opts).html_safe
        end
        content_tag(:ul, content.html_safe, opts).html_safe
      end
      
      # This is hacked this together.
      # It is working at the moment but needs further work.
      # - Yuri
      def page_url(path_or_page , opts = {})
        if path_or_page.is_a?(String)
          if Gluttonberg.localized?
            "/#{opts[:slug]}/#{path_or_page}"
          else
            "/#{path_or_page}"
          end
        else
          if path_or_page.rewrite_required?
            url = Rails.application.routes.recognize_path(path_or_page.description.rewrite_route)
            url[:host] = Rails.configuration.host_name
            Rails.application.routes.url_for(url)
          else
            if Gluttonberg.localized?
              "/#{opts[:slug]}/#{path_or_page.path}"
            else
              "/#{path_or_page.path}"
            end
          end
        end
      end
      
      # Returns the code for google analytics
      def google_analytics_js_tag
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
      
      def keywords_meta_tag
        content_tag(:meta , "" , :content => Rails.configuration.gluttonberg[:keywords] , :name => "keywords")
      end 
      
      def description_meta_tag
        content_tag(:meta , "" , :content => Rails.configuration.gluttonberg[:description] , :name => "description")
      end
      
      def render_match_partial(result)
        begin
          klass = result.class.name.demodulize.underscore
          render :partial => "search/#{klass}", :locals => { :result => result }
        rescue ActionView::MissingTemplate => e
          "Missing search template for model #{klass}. Create a search/_#{klass}.html.erb partial in the correct plugin and try again."
        rescue RuntimeError => e
          "Unable to find the class name of the following match #{debug result}"
        end
      end
      
    end # Public
  end # Helpers
end # Gluttonberg
