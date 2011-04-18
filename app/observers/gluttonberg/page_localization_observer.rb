module Gluttonberg
  class PageLocalizationObserver < ActiveRecord::Observer
    observe PageLocalization

    # Every time the localization is updated, we need to check to see if the 
    # slug has been updated. If it has, we need to update it's cached path
    # and also the paths for all it's decendants.
    def before_validation(page_localization)
      if page_localization.slug_changed? || page_localization.new_record?
        page_localization.paths_need_recaching = true
        page_localization.regenerate_path 
      elsif page_localization.path_changed? 
        page_localization.paths_need_recaching = true
      end
    end

    # This is the business end. If the paths do have to be recached, we pile
    # through all the decendent localizations and tell each of those to recache.
    # Each of those will then also be observed and have their children updated
    # as well.
    def after_save(page_localization)
      if page_localization.paths_need_recaching? and !page_localization.page.children.blank?
        decendant_pages = page_localization.page.children
        
        decendant_pages.each do |d_p|
          decendants = d_p.localizations.find( :all , :conditions => {:locale_id => page_localization.locale_id})          
          unless decendants.blank?
            decendants.each do |l| 
              l.paths_need_recaching = true
              l.update_attributes(:path => "#{page_localization.path}/#{l.slug || l.page.slug}") 
            end 
          end
        end#loop  
      end
    end
  end
end

