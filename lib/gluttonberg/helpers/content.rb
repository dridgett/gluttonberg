module Gluttonberg
  module Helpers
    module Content
      # Finds the matching content block and determines the helper it needs
      # to execute to actually write the contents to page.
      # TODO: if there is no way to to render the content, freak out and raise
      # an error
      def render_content_for(section_name, opts = {})
        # At present this generates a bunch of queries. Eventually we should 
        # look at caching section names to save some DB hits.
        content = content_for(section_name)
        render_method = :"render_#{content.content_type}"
        if respond_to? render_method
          send(:"render_#{content.content_type}", content, opts)
        elsif content.respond_to? :text
          content.text
        else
          # raise Gluttonberg::ContentRenderError, "Don't know how to render this content"
        end
      end

      # Returns the content record for the specified section. It will include
      # the relevant localized version based the current locale/dialect
      def content_for(section_name, opts = nil)
        section_name = section_name.to_sym         
        @page.localized_contents.pluck {|c| c.section[:name] == section_name}
      end

      # Render html content. Actually just looks for the text 
      # property on the content model.
      def render_html_content(content, opts = nil)
        if content.current_localization.text
          content.current_localization.text.html_safe
        else
          ""
        end 
      end
      
      
      # Renders an image tag with the src set to the associated asset. If the
      # asset is missing it returns nil.
      def render_image_content(content, opts = {})
        if content.asset
          if opts[:url_for].blank?
            image_tag(content.asset.url, opts.merge!(:alt => content.asset.name))
          else
            image_tag(content.asset.url_for(opts[:url_for].to_sym), opts.merge!(:alt => content.asset.name))              
          end
        end
      end

      # Simple as it gets, it just pulles the text property from the content 
      # record
      def render_plain_text_content(content, opts = nil)
        content.current_localization.text
      end

      # Looks for a matching partial in the templates directory. Failing that, 
      # it falls back to Gluttonberg's view dir — views/content/editors
      def content_editor(content_class)
        locals  = {:content => content_class}
        type    = content_class.content_type 
        render :partial => "/gluttonberg/admin/content/editors/#{type}", :locals => locals
      end
      
      # generate javascript code to enable tinymce on it. textArea need to have class = jwysiwyg
      def enable_jwysiwyg_on_class(html_class)        
        if Rails.configuration.gluttonberg[:enable_WYSIWYG] == "Yes"
          content = "enable_jwysiwyg_on('.#{html_class}'); \n"        
          content_tag(:script , content , :charset=>'utf-8', :type=>'text/javascript')        
        end  
      end
      
    end # Content
  end # Helpers
end # Gluttonberg
