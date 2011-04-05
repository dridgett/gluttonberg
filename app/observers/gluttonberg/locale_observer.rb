module Gluttonberg
  class LocaleObserver < ActiveRecord::Observer
    observe Locale
    
    def after_create(locale)   
      pages = Page.all
      
      pages.each do |page|
        #create localizations for all pages for new locale
        new_localizations = []
        locale.dialects.all.each do |dialect|
          new_localizations << page.localizations.create(
            :name     => page.name,
            :dialect_id  => dialect.id,
            :locale_id   => locale.id
          )
        end   
        
        # create content localizations
        unless page.description.sections.empty?
          Rails.logger.info("Generating stubbed content for all pages using new localizations")
          page.description.sections.each do |name, section|
            # Create the content
              association = page.send(section[:type].to_s.pluralize)
              content = association.find(:first , :conditions => {:section_name => name})
              # Create each localization
               if content && content.class.localized?
                   new_localizations.each do |localization|
                     content.localizations.create(:parent => content, :page_localization => localization)
                   end
              end
          end
        end
        
      end
      
    end

      
    
    def after_update(locale)   
      dialect_ids = locale.dialect_ids
      existing_localization_ids = []
      remove_list = []
      new_localizations = []
      
      page_localizations = PageLocalization.find(:all , :conditions => {:locale_id => locale.id})
      
      
      page_localizations.each do |loc|
        if dialect_ids.include? loc.dialect_id
          existing_localization_ids << loc.dialect_id
        else
          remove_list << loc.dialect_id
        end
      end
      
      dialect_ids.delete_if{|d| existing_localization_ids.include?(d) } 
      # #create new localization
      pages = Page.all
      pages.each do |page|
        #create localizations for all pages for new locale
        dialect_ids.each do |dialect_id|
          new_localizations << page.localizations.create(
              :name     => page.name,
              :dialect_id  => dialect_id,
              :locale_id   => locale.id
          )
        end  
      end
      
      
      
      #create_localized_content_for(new_localizations)        
      new_localizations.each do |localization|
         page = localization.page
         
         unless page.description.sections.empty?
           page.description.sections.each do |name, section|
             # Create the content
               association = page.send(section[:type].to_s.pluralize)
               content = association.find(:first , :conditions => {:section_name => name})
               if content && content.class.localized?
                  content.localizations.create(:parent => content, :page_localization => localization)  
               end
           end
         end
      end
      
      
      
      
      #remove localizations which are not required anymore
      PageLocalization.delete_all(:dialect_id => remove_list , :locale_id => locale.id)
      
    end  
        
  end
end