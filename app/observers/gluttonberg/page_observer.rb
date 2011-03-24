module Gluttonberg
  class PageObserver < ActiveRecord::Observer

    observe Page

    # Generate a series of content models for this page based on the specified
    # template. These models will be empty, but ready to be displayed in the 
    # admin interface for editing.
    def after_create(page)    
      puts("Generating page localizations")
      Locale.all.each do |locale|
        locale.dialects.all.each do |dialect|
          loc = page.localizations.create(
            :name     => page.name,
            :dialect_id  => dialect.id,
            :locale_id   => locale.id
          )
        end
      end
        
      unless page.description.sections.empty?
        puts("Generating stubbed content for new page")
        page.description.sections.each do |name, section|
          # Create the content
              association = page.send(section[:type].to_s.pluralize)
              content = association.create(:section_name => name)
              # Create each localization
               if content.class.localized?
                   page.localizations.all.each do |localization|
                     content.localizations.create(:parent => content, :page_localization => localization)
                   end
              end
        end
      end
    end
    
    
    def before_update(page)    
      # This checks to make see if we need to regenerate paths for child-pages
      # and adds a flag if it does.
      if page.parent_id_changed? || page.slug_changed? 
        @paths_need_recaching = true
      end
    end
    
    def before_save(page)    
      # We also need to check if the depths need to be recalculated for this
      # page and for it's children
      #if attribute_dirty?(:parent_id) || new_record?
      if page.parent_id_changed? || page.new_record?
        if page.parent_id
          #set_depth(page.parent.depth + 1)
        else
          #set_depth(0)
        end
      end
    end

    def after_update(page)    
      # This has the page localizations regenerate their path if the slug or 
      # parent for this page has changed.
      if page.paths_need_recaching?
        localizations.each { |l| l.regenerate_path! }
      end
      
      # Set off some code which causes a recursion through all the child pages
      # and updates their depth
      if page.depths_need_recaching
        children.each { |c| c.set_depth!(page.depth + 1) }
      end
    end
    
    # A dirty hack to remove the page localizations after a page is destroyed.
    # This is in lieu of a :dependent option in DM associations
    def after_destroy(page)    
      page_localizations = PageLocalization.find(:all , :conditions => { :page_id => page.id })
      page_localization_ids = page_localizations.collect { |l| l.id }
      # Destroy the localizations first, then the main content record
      unless page_localization_ids.blank?
        Gluttonberg::Content.content_classes.each do |klass|
          if klass.localized?
            Gluttonberg.const_get( "#{klass.name.demodulize}Localization" ).delete_all(:page_localization_id => page_localization_ids)
            #klass.localizations.model.all(:page_localization_id => page_localization_ids).destroy!
          end
          klass.delete_all(:page_id => page.id)
          #klass.find(:all , :conditions => { :page_id => page.id } ).destroy!
        end
        page_localizations.each do |page_localization|
          PageLocalization.destroy(page_localization.id)
        end
        #PageLocalization.destroy_all("'id' in '#{page_localization_ids}'" ) 
        #page_localizations.destroy!
      end  
    end
  end
end