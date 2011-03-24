module Gluttonberg
  module Helpers
    module AssetLibrary
      # Controls for standard forms. Writes out a save button and a cancel link
       def form_controls(return_url)
         content = "<button class='button' type='submit'><img alt='Save' src='/images/save.jpg'>Save</button> #{link_to("<button class='button'><img alt='Cancel' src='/images/cancel.jpg'>Cancel</button>", return_url)}"
         content_tag(:p, content, :class => "controls")
       end


       #  nice and clean public url of assets
       def asset_url(asset)
         if RAILS_ENV=="development"
           "http://#{request.host}:#{request.port}/asset/#{asset.asset_hash[0..3]}/#{asset.id}"
         else
           "http://#{request.host}/asset/#{asset.asset_hash[0..3]}/#{asset.id}"
         end     
       end

       # Returns a link for sorting assets in the library
       def sorter_link(name, param, url)
         opts = {}
         if param == params[:order] || (!params[:order] && param == 'date-added')
           opts[:class] = "current"
         end

         route_opts = { :order => param  }

         link_to(name, url + "?" + route_opts.to_param , opts)
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
       #    #   
       #
       # Example (bound):
       #   asset_browser(:thumbnail_id, form_context ,:label => "Thumbnail")
       # For Finding image assets
       #   asset_browser(:thumbnail_id, form_context ,:label => "Thumbnail" , :filter => "image")   other filters are audio video
       #
       def asset_browser_old( field_id , form_context , opts = {} )
         id = opts[:form_object_id].blank? ? form_context.object.id : opts[:form_object_id]
         asset_id = form_context.object.send(field_id.to_s)
         filter = opts[:filter].blank? ? "all" : opts[:filter]


         rel = field_id.to_s + "_" + id.to_s
         opts[:id] = rel

         button_text = opts[:button_text].blank? ? "Browse" : opts[:button_text]


        # Find the asset so we can get the name
        asset_info = "Nothing selected"
        unless asset_id.blank?
          asset = Asset.find(asset_id)
          asset_info = if asset
            asset.name
          else
            "Asset missing!"
          end    
        end

         # Output it all
        link_contents =  content_tag(:span , asset_info) 
        link_contents << hidden_field_tag("filter_" + field_id.to_s , value=filter , :id => "filter_#{rel}" )
        link_contents << link_to(button_text, admin_asset_browser_url + "?filter=#{filter}" , { :class => opts[:button_class] , :rel => rel })
        link_contents << form_context.hidden_field(field_id, opts.merge(:class => "choose_asset_hidden_field"))

        content_tag(:span , link_contents , { :class => "assetBrowserLink" } )         
       end
       
       def asset_browser( field_id , opts = {} )
          asset_id = nil
          #asset_id = form_context.object.send(field_id.to_s)
          filter = opts[:filter].blank? ? "all" : opts[:filter]


          rel = field_id.to_s + "_" + id.to_s
          opts[:id] = rel

          button_text = opts[:button_text].blank? ? "Browse" : opts[:button_text]


         # Find the asset so we can get the name
         asset_info = "Nothing selected"
         unless asset_id.blank?
           asset = Asset.find(asset_id)
           asset_info = if asset
             asset.name
           else
             "Asset missing!"
           end    
         end

          # Output it all
         link_contents =  content_tag(:span , asset_info) 
         link_contents << hidden_field_tag("filter_" + field_id.to_s , value=filter , :id => "filter_#{rel}" )
         link_contents << link_to(button_text, admin_asset_browser_url + "?filter=#{filter}" , { :class => opts[:button_class] , :rel => rel })
         link_contents << hidden_field_tag(field_id , nil , opts.merge(:class => "choose_asset_hidden_field"))

         content_tag(:span , link_contents , { :class => "assetBrowserLink" } )         
        end

       

       def asset_paginator(assets , name_or_id , type)
          html = ""
          if assets.total_pages > 1
            html = "<ul id='paginator' >"
              html << "<li id='count'>Page #{assets.current_page} of #{assets.total_pages} </li>"
              if assets.previous_page
                url = ( type == "category" ?  admin_asset_category_url(:category => name_or_id , :page => assets.previous_page ) : admin_asset_collection_url(:id => name_or_id , :page => assets.previous_page )  ) 
                html << "<li id='previous'> #{link_to("Previous", url )} </li>"            
              else
                html << "<li id='previous' class='disabled' > #{ link_to("Previous") } </li>"            
              end
              if assets.next_page
                url = ( type == "category" ?  admin_asset_category_url(:category => name_or_id , :page => assets.next_page ) : admin_asset_collection_url(:id => name_or_id , :page => assets.next_page )  )
                html << "<li id='next'> #{link_to("Next", url )} </li>"  
              else
                html << "<li id='next'   class='disabled'  > #{link_to("Next")} </li>"              
              end
            html << "</ul>"         
          end  
          html
       end   

       def asset_panel(assets, name_or_id , type)
          html = ""
          if assets.blank?
            if @category_filter.blank? || @category_filter == "all"  
              html << "<p class='empty'>No assets</p>"
            else
              html << "<p class='empty'>No #{@category_filter} assets</p>"
            end  
          else
            html << "<ul id='assetPanels'> " 
              for asset in @assets
                html << '<li>'
                  #html << "<a href='#{admin_asset_url(asset)}' class='assetLink' rel='#{asset.type}' >"
                  html << "<a href='#{admin_asset_url(asset)}' class='assetLink' rel='#{asset.category.name}' >"
                    html << "<h2> #{asset.name} </h2>"
                    html << "<p>Added #{asset.created_at}</p>"
                    html << "<div> <img src='#{asset.thumb_small_url}' /> </div>"
                  html << "</a>" 
                html << '</li>'              
              end #loop
             html << "</ul>"

             html << asset_paginator(assets, name_or_id , type)

          end #if    
          html  
       end

       def asset_tag_from_form(field_id , form_context , thumbnail_type = nil)
          asset_id = form_context.object.send(field_id.to_s)
          unless asset_id.blank? 
            asset = Asset.find(:first ,:conditions => { :id => asset_id } )
            unless asset.blank?
              asset_tag(asset , thumbnail_type )
            end
          end
        end


       def asset_tag(asset , thumbnail_type = nil)
         unless asset.blank?
           path = asset.url
           unless thumbnail_type.blank?
             path = asset.url_for(thumbnail_type)
           end
           "<img title='#{asset.name}' alt='#{asset.name}' src='#{path}' />"
         end 
       end
     
     
     
    end # Assets
  end # Helpers
end # Gluttonberg

