# encoding: utf-8
# Do not remove above encoding line utf-8, its required for ruby 1.9.2. We are using some special chars in this file.

module Gluttonberg
  class Page < ActiveRecord::Base
    include Content::Publishable
    
    has_many :localizations, :class_name => "Gluttonberg::PageLocalization"   , :dependent => :destroy 

    # Generate the associations for the block/content classes
    Content::Block.classes.each do |klass| 
      has_many klass.association_name, :class_name => klass.name, :dependent => :destroy
    end

    
    validates_presence_of :name , :description_name
    
    set_table_name "gb_pages"
       
    
    before_validation :slug_management
    after_save   :check_for_home_update

    is_drag_tree :scope => :parent_id, :flat => false , :order => "position"
    
    attr_accessor :current_localization, :dialect_id, :locale_id, :paths_need_recaching
    
    
    # A custom finder used to find a page + locale combination which most
    # closely matches the path specified. It will also optionally limit it's
    # search to the specified locale, otherwise it will fall back to the
    # default.
    def self.find_by_path(path, locale = nil)
      unless locale.blank?
          path = path.match(/^\/(\S+)/)[1]
          page = joins(:localizations).where("locale_id = ? AND path LIKE ?", locale.id, "#{path}%")
          unless page.blank?   
            page = page.first
            page.current_localization = page.localizations.where("locale_id = ? AND path LIKE ?", locale.id,  "#{path}%").first
          end  
          page
      end  
    end

    # Indicates if the page is used as a mount point for a public-facing
    # controller, e.g. a blog, message board etc.
    def mount_point?
      #false
      self.description.redirection_required?
    end
    
    def mount_path(path=nil) 
      if path.blank?
        self.description.rewrite_route
      end
    end
            
    # Returns the PageDescription associated with this page.
    def description
      @description = PageDescription[self.description_name.to_sym] if self.description_name
    end
    
    # Returns the name of the view template specified for this page —
    # determined via the associated PageDescription
    def view
      self.description if @description.blank? 
      @description[:view] if @description
    end
    
    # Returns the name of the layout template specified for this page —
    # determined via the associated PageDescription
    def layout
      self.description if @description.blank? 
      @description[:layout] if @description
    end
    
    # Returns the localized navigation label, or falls back to the page for a
    # the default.
    def nav_label
      if current_localization.blank? || current_localization.navigation_label.blank?
        if navigation_label.blank?
          name
        else
          navigation_label
        end
      else
        current_localization.navigation_label
      end
    end

    # Returns the localized title for the page or a default
    def title
      current_localization.name.blank? ? attribute_get(:name) : current_localization.name
    end
    
    # Delegates to the current_localization
    def path
      unless current_localization.blank?
        current_localization.path
      else
        localizations.first.path
      end  
    end
    

    def slug=(new_slug)
      #if you're changing this regex, make sure to change the one in /javascripts/slug_management.js too
      # utf-8 special chars are fixed for new ruby 1.9.2
      new_slug = new_slug.downcase.gsub(/\s/, '_').gsub(/[\!\*'"″′‟‛„‚”“”˝\(\)\;\:\@\&\=\+\$\,\/?\%\#\[\]]/, '')
      write_attribute(:slug, new_slug)
    end

    def paths_need_recaching?
      @paths_need_recaching
    end

    # Just palms off the request for the contents to the current localization
    def localized_contents
      @contents ||= begin
        Content.content_associations.inject([]) do |memo, assoc|
          memo += send(assoc).all_with_localization(:page_localization_id => current_localization.id)
        end
      end
    end

    
    # Load the matching localization as specified in the options
    def load_localization(locale = nil)
      @current_localization = localizations.where("locale_id = ? AND dialect_id = ? AND path LIKE ?", locale.id, locale.dialect_id, "#{path}%").first unless conditions.empty?
    end

    def home=(state)
      write_attribute(:home, state)
      @home_updated = state
    end
        
    private

      def slug_management
        self.slug= name if self.slug.blank?
      end

      # Checks to see if this page has been set as the homepage. If it has, we 
      # then go and 
      def check_for_home_update
        if @home_updated && @home_updated == true
          previous_home = Page.find( :first ,  :conditions => [ "home = ? AND id <> ? " , true ,id ] )
          previous_home.update_attributes(:home => false) if previous_home
        end
      end
    
  end
end


