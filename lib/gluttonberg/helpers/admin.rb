module Gluttonberg
  module Helpers
    # Helpers specific to the administration interface. The majority are 
    # related to forms, but there are other short cuts for things like navigation.
    module Admin
      
      # Returns a form for selecting the localized version of a record you want 
      # to edit.
      # TODO DO we need that 
      def localization_picker(url)
        # Collect the locale/dialect pairs
        locales = ::Gluttonberg::Locale.all(:fields => [:id, :name])
        localizations = []
        locales.each do |locale|      
            localizations << ["#{locale.id}", "#{locale.name}"]
        end
        # Output the form for picking the locale
        form(:action => url, :method => :get, :id => "select-localization") do
          output = ""
          output << select(:name => :localization, :collection => localizations, :label => "Select localization", :selected => params[:localization])
          output << button("Edit", :class => "buttonGrey")
        end
      end
      
      # Returns a form for selecting the localized version of a record you want 
      # to edit.
      def page_localization_picker(page_localizations)
        
      end
            

      # Returns a text field with the name, id and values for the localized
      # version of the specified attribute.
      def localized_text_field(name, opts = {})
        final_opts = localized_field_opts(name)
        text_field(final_opts.merge!(opts))
      end
      
      # Returns a text area with the name, id and values for the localized
      # version of the specified attribute.
      def localized_text_area(name, opts = {})
        text_area(get_localized_value(name), localized_field_opts(name, false).merge!(opts))
      end

      # Returns a hash of common options to be used in the localized versions 
      # of fields.
      def localized_field_opts(name, set_value = true)
        prefix = current_form_context.instance_variable_get(:@name)
        opts = {
          :name   => "#{prefix}[localized_attributes][#{name}]",
          :id     => "#{prefix}_localized_#{name}"
        }
        opts[:value] = get_localized_value(name) if set_value
        opts
      end

      # Returns a hidden field which stores the localization param in the form.
      def localization_field
        hidden_field(:name => "localization", :value => params[:localization])
      end

      def get_localized_value(name)
        @localized_model ||= current_form_context.instance_variable_get(:@obj)
        @localized_model.current_localization.send(name)
      end
      
      # Checks to see if there is a matching help page for this particular 
      # controller/action. If there is it renders a link to the help 
      # controller.
      def contextual_help             
        if Help.help_available?(:controller => params[:controller], :page => params[:action])
          content_tag(
            :p, 
            link_to("Help", admin_help_path(:module_and_controller => params[:controller], :page => params[:action])),
            :id => "contextualHelp"
          )          
        end
      end

      # TODO Do we need these?
      # Generates a styled tab bar
      def tab_bar(&blk)
        content_tag(:ul, {:id => "tabBar"}, &blk)
      end

      # For adding a tab to the tab bar. It will automatically mark the current
      # tab by examining the request path.
      def tab(label, url)
        if request.env["REQUEST_PATH"] && request.env["REQUEST_PATH"].match(%r{^#{url}})
          content_tag(:li, link_to(label, url), :class => "current")
        else
          content_tag(:li, link_to(label, url))
        end
      end

      # If it's passed a label this method will return a fieldset, otherwise it
      # will just return the contents wrapped in a block.
      def block(label = nil, opts = {}, &blk)
        (opts[:class] ||= "") << " fieldset"
        opts[:class].strip!
        if label
          field_set_tag(label) do
            content_tag(:div, opts, &blk)
          end
        else
          content_tag(:div, opts, &blk)
        end
      end

      # Controls for standard forms. Writes out a save button and a cancel link
      def form_controls(return_url)
        content = "#{submit_tag("Save").html_safe} or #{link_to("<strong>Cancel</strong>".html_safe, return_url)}"
        content_tag(:p, content.html_safe, :class => "controls")
      end
      
      # Controls for publishable forms. Writes out a draft ,  publish/unpublish button and a cancel link
      def publishable_form_controls(return_url , object_name , is_published )
        content = hidden_field(:published , :value => false) 
        content += "#{submit_tag("draft")}"        
        content += " or #{submit_tag("publish" , :onclick => "publish('#{object_name}_published')" )} "
        content += " or #{link_to("<strong>Cancel</strong>", return_url)}"
        content_tag(:p, content, :class => "controls")
      end

      # Writes out a nicely styled subnav with an entry for each of the 
      # specified links.
      def sub_nav(&blk)
        content_tag(:ul, :id => "subnav", &blk)
      end

      # Writes out a link styled like a button. To be used in the sub nav only
      def nav_link(*args)             
        content_tag(:li, link_to(args[0] , args[1] , :title => args[0]), :class => "button")
      end

      # Writes out the back control for the sub nav.
      def back_link(name, url)        
        content_tag(:li, link_to(name, url , :title => name), :id => "backLink")
      end

      # Takes text and url and checks to see if the path specified matches the 
      # current url. This is so we can add a highlight.
      def main_nav_entry(text, mod, url = nil, opts = {})
        if url
          li_opts = {:id => "#{mod}Nav"}
          if( ( request.env["REQUEST_PATH"] && (request.env["REQUEST_PATH"].match(%r{/#{mod}}) || request.env["REQUEST_PATH"] == url) )  || (request.env["REQUEST_PATH"] && request.env["REQUEST_PATH"].include?("content") && request.env["REQUEST_PATH"] == url ) )
            li_opts[:class] = "current"
          end
          content_tag("li", link_to(text, url, opts), li_opts)
        end
      end
     
      def gb_error_messages_for(model_object)
        if model_object.errors.any?
            lis = ""
            model_object.errors.full_messages.each do |msg|
              lis << content_tag(:li , msg)
            end 
          ul = content_tag(:ul , lis.html_safe).html_safe
          content_tag(:div , ul , :class => "error")
        end
      end
      
      def website_title
        title = Engine.config.app_name 
        (title.blank?)? "Gluttonberg" : title.html_safe
      end  
      
      #Returns a link for sorting assets in the library
      def sorter_link(name, param, url)
        opts = {}
         if param == params[:order] || (!params[:order] && param == 'date-added')
           opts[:class] = "current"
         end

         route_opts = { :order => param  }

         link_to(name, url + "?" + route_opts.to_param , opts)
      end

      # Writes out a row for each page and then for each page's children, 
      # iterating down through the heirarchy.
      def page_table_rows(pages, output = "", inset = 0 , row = 0)
        pages.each do |page|
          row += 1 
          output << render( :partial => "gluttonberg/admin/content/pages/row", :locals => { :page => page, :inset => inset , :row => row })
          page_table_rows(page.children, output, inset + 1 , row)
        end
        output.html_safe
      end
      
      
      def publisable_dropdown(form ,object)
        val = object.state
        val = "ready" if val.blank? || val == "not_ready"
        @@workflow_states = [  [ 'Draft' , 'ready' ] , ['Published' , "published" ] , [ "Archived" , 'archived' ]  ]
        form.select( :state, options_for_select(@@workflow_states , val)   ) 
      end
      
      # shows publish message if object's currect version is published
      def publish_message(object , versions)
        content = msg = ""

        if versions.length > 1
          msg = content_tag(:a,  "Click here to see other versions" , :onclick => "$('#select-version').toggle();" , :href => "javascript:;"  , :title => "Click here to see other versions").html_safe
          msg = content_tag(:span , msg , :class => "view-versions").html_safe
        end

        content = content_tag(:div , "Updated on #{object.updated_at.to_s(:long)}    #{msg}".html_safe , :class => "unpublish_message") unless object.updated_at.blank?
        content.html_safe
      end
      
      def version_listing(versions , selected_version_num )
        output = "<div class='historycontrols'>"
          selected = versions.last.version
          selected_version = versions.last
          collection = []
          versions.each do |version|
            link = version.version
            snippet = "V#{version.version} - Updated #{version.updated_at.to_s(:long)}  "  unless version.updated_at.blank?        
            if version.version.to_i == selected_version_num.to_i
              selected = link      
              selected_version   = version   
            end  
            collection << [snippet , link]
          end 

          output << publish_message(selected_version , versions )

          # Output the form for picking the version
            output << "<form  method='get' id = 'select-version' style='display:none;'> "
            output << select_tag(:version, options_for_select( collection , selected ) , :id => "version_drop" )
            output << submit_tag("Preview", :class => "buttonGrey" , :id => "change_verson_btn" , :name => nil ) 
            output << "</form>"

          output += "</div>"
          output += "<div class='clear'></div>"
          output += "<br />"
          output += "<br />"
          output.html_safe
        end
      
      def custom_stylesheet_link_tag
        if Rails.configuration.gluttonberg[:custom_css_for_cms] == "Yes"
          stylesheet_link_tag "custom"
        end  
      end
      
      def wysiwyg_js_css_link_tag
        if Rails.configuration.gluttonberg[:enable_WYSIWYG] == "Yes"
          stylesheet_link_tag("/javascripts/akzhan-jwysiwyg-2b20f74/jquery.wysiwyg.css") + javascript_include_tag("akzhan-jwysiwyg-2b20f74/jquery.wysiwyg.js")
        end
      end
      
    end # Admin
  end # Helpers
end # Gluttonberg
