module Gluttonberg
  module Helpers
    # Helpers specific to the administration interface. The majority are 
    # related to forms, but there are other short cuts for things like navigation.
    module Admin
      # This checks to see if there have been any editors defined for the 
      # content records associated with a page. These are partials that live in
      # "<ROOT>/templates/editors/pages/"
      def page_editors?
        glob = dir = Gluttonberg::Templates.path_for("editors") / "pages" / "*"
        !Dir[glob].empty?
      end
      
      # Returns a collection of paths paths to the content editors to be used
      # by a page.
      def page_editors
        dir = Gluttonberg::Templates.path_for("editors") / "pages"
        Dir[dir / "*"].inject("") do |output, editor|
          output << partial(dir / editor.match(/\/_(\w+)\.\S+/)[1])
        end
      end
      
      # Returns a form for selecting the localized version of a record you want 
      # to edit.
      def localization_picker(url)
        # Collect the locale/dialect pairs
        locales = ::Gluttonberg::Locale.all(:fields => [:id, :name])
        localizations = []
        locales.each do |locale|      
          locale.dialects.each do |dialect|
            localizations << ["#{locale.id}-#{dialect.id}", "#{locale.name} - #{dialect.name}"]
          end
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
          tag(
            :p, 
            link_to("Help", url(:gluttonberg_help, :module_and_controller => params[:controller], :page => params[:action])),
            :id => "contextualHelp"
          )
        end
      end
      
      # Generates a link which launches the asset browser
      # This method operates in bound or unbound mode.
      #
      # In bound mode method accepts two arguments, the first argument must be the models
      # relationship field to accept the asset (as a symbol) as per merbs bound form controls.
      # The second argument is the options hash.
      #
      # In unbound mode the method accepts one argument an options hash.
      #
      # The options hash accepts the following parameters:
      #
      #   The following are required in unbound mode, not used in bound mode:
      #     :id = This is the id to use for the generated hidden field to store the selected assets id.
      #     :value = The id of the currently selected asset. ode)
      #
      #   The following are optional in either mode:
      #     < any option accepted by hidden_field() method >
      #
      # Example (unbound):
      #   asset_browser(
      #       :value => content.asset_id,
      #       :id => "page_image_#{content.id}",
      #       :name => "gluttonberg::page_localization[contents][#{content.association_name}][#{content.id}][asset_id]"
      #   )
      #
      # Example (bound):
      #   asset_browser(:thumbnail_id, :label => "Thumbnail")
      #
      def asset_browser(*args)
        bound = bound?(*args)
        if bound
          opts = args.length > 1 ? args.last : {}
          # do something clever to get the current obj, hence the fieldname
          rel = "#{current_form_context.instance_variable_get(:@name)}_#{args.first}"
          asset_id = current_form_context.send(:control_value, args.first)
        else
          opts = args.first
          rel = opts[:id]
          asset_id = opts[:value]
        end
        # Find the asset so we can get the name
        asset_name, indicator = unless asset_id.nil?
          asset = Gluttonberg::Asset.get(asset_id, :fields => [:name, :category])
          if asset
            [asset.name, asset.category]
          else
            ["Asset missing!", "missing"]
          end
        else
          ["Nothing selected", "default"]
        end
        # Output it all
        link_contents = "<strong class=\"#{indicator}\">#{asset_name}</strong>"
        link_contents << link_to("Browse", url(:gluttonberg_asset_browser), :class => "buttonGrey", :rel => rel)
        link_contents << link_to("Remove", "#{}", :class => "buttonGrey clear-asset", :rel => "clear-asset")
        link_contents << (bound ? hidden_field(args.first, opts) : hidden_field(opts))
        output = ""
        output << tag(:label, opts[:label]) if opts[:label]
        output << tag(:p, link_contents, :class => "assetBrowserLink")
        
        
      end

      # Creates a link tag that shows the AssetBrowser popup
      def link_to_asset_browser(name, opts={})

        # work out the updating url for the collection from opts[:collection]
        add_asset_url = slice_url(:add_asset_to_collection, opts[:collection].id)

        js_code = <<JAVASCRIPT_CODE
showAssetBrowser({rootUrl: '#{url(:gluttonberg_asset_browser)}', onSelect: function(assetId){writeAssetToAssetCollection(assetId,'#{add_asset_url}')}}); return false;
JAVASCRIPT_CODE
        opts[:onclick] = opts[:onclick] || js_code
        link_to(name, '#', opts)
      end

      # Writes out a link styled like a button. To be used in the sub nav only
      def asset_browser_nav_link(*args)
        tag(:li, link_to_asset_browser(*args), :class => "button")
      end

      # Generates a styled tab bar
      def tab_bar(&blk)
        tag(:ul, {:id => "tabBar"}, &blk)
      end

      # For adding a tab to the tab bar. It will automatically mark the current
      # tab by examining the request path.
      def tab(label, url)
        if request.env["REQUEST_PATH"] && request.env["REQUEST_PATH"].match(%r{^#{url}})
          tag(:li, link_to(label, url), :class => "current")
        else
          tag(:li, link_to(label, url))
        end
      end

      # If it's passed a label this method will return a fieldset, otherwise it
      # will just return the contents wrapped in a block.
      def block(label = nil, opts = {}, &blk)
        (opts[:class] ||= "") << " fieldset"
        opts[:class].strip!
        if label
          fieldset({:legend => label}) do
            tag(:div, opts, &blk)
          end
        else
          tag(:div, opts, &blk)
        end
      end

      # Controls for standard forms. Writes out a save button and a cancel link
      def form_controls(return_url)
        content = "#{submit("Save")} or #{link_to("<strong>Cancel</strong>", return_url)}"
        tag(:p, content, :class => "controls")
      end
      
      # Controls for publishable forms. Writes out a draft ,  publish/unpublish button and a cancel link
      def publishable_form_controls(return_url , object_name , is_published )
        content = hidden_field(:published , :value => false) 
        content += "#{submit("draft")}"        
        content += " or #{submit("publish" , :onclick => "publish('#{object_name}_published')" )} "
        #content += " or #{submit("unpublish" )} " if is_published
        content += " or #{link_to("<strong>Cancel</strong>", return_url)}"
        tag(:p, content, :class => "controls")
      end

      # Writes out a nicely styled subnav with an entry for each of the 
      # specified links.
      def sub_nav(&blk)
        tag(:ul, :id => "subnav", &blk)
      end

      # Writes out a link styled like a button. To be used in the sub nav only
      def nav_link(*args)             
        tag(:li, link_to(args[0] , args[1] , :title => args[0]), :class => "button")
      end

      # Writes out the back control for the sub nav.
      def back_link(name, url)        
        tag(:li, link_to(name, url , :title => name), :id => "backLink")
      end

      # Takes text and url and checks to see if the path specified matches the 
      # current url. This is so we can add a highlight.
      def main_nav_entry(text, mod, url = nil, opts = {})
        if url
          li_opts = {:id => "#{mod}Nav"}
          if( ( request.env["REQUEST_PATH"] && (request.env["REQUEST_PATH"].match(%r{/#{mod}}) || request.env["REQUEST_PATH"] == url) )  || (request.env["REQUEST_PATH"] && request.env["REQUEST_PATH"].include?("content") && request.env["REQUEST_PATH"] == url ) )
            li_opts[:class] = "current"
          end
          tag("li", link_to(text, url, opts), li_opts)
        end
      end
      
      def admin_rights_form(user)        
         if user.is_super_admin                     
          hidden_field(:is_super_admin , :value=>true)
         else
           hidden_field(:is_super_admin , :value=>false)
         end 
      end
     

      
      def website_title
        title = Merb::Slices::config[:gluttonberg][:title]
        (title.blank?)? "Gluttonberg" : title
      end  
      
      def meta_keywords
        Merb::Slices::config[:gluttonberg][:keywords]
      end 
      
      def meta_description
        Merb::Slices::config[:gluttonberg][:description]
      end
      
      def asset_url(asset)
        "http://#{request.host}/asset/#{asset.asset_hash[0..3]}/#{asset.id}"
      end  
      
      
      
    end # Admin
  end # Helpers
end # Gluttonberg
