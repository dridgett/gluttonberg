# encoding: utf-8
# Do not remove above encoding line utf-8, its required for ruby 1.9.2. We are using some special chars in this file.

module Gluttonberg
  class Page < ActiveRecord::Base
    include Content::Publishable
    include Content::SlugManagement
    belongs_to :user
    has_many :localizations, :class_name => "Gluttonberg::PageLocalization"   , :dependent => :destroy 

    # Generate the associations for the block/content classes
    Content::Block.classes.each do |klass| 
      has_many klass.association_name, :class_name => klass.name, :dependent => :destroy
    end
    
    validates_presence_of :name , :description_name
    
    set_table_name "gb_pages"
    
    after_save   :check_for_home_update

    is_drag_tree :scope => :parent_id, :flat => false , :order => "position"
    
    attr_accessor :current_localization, :locale_id, :paths_need_recaching
    
    
    # A custom finder used to find a page + locale combination which most
    # closely matches the path specified. It will also optionally limit it's
    # search to the specified locale, otherwise it will fall back to the
    # default.
    def self.find_by_path(path, locale = nil)
      path = path.match(/^\/(\S+)/)
      unless locale.blank? || path.blank?
        path = path[1]        
        page = joins(:localizations).where("locale_id = ? AND ? LIKE path || '%'", locale.id, path).first
        unless page.blank? 
          page.current_localization = page.localizations.where("locale_id = ? AND ? LIKE path || '%'", locale.id,  path).first
        end  
        page
      else
        locale = Gluttonberg::Locale.first_default if locale.blank?
        pages = joins(:localizations).where("locale_id = ? AND home = ?", locale.id, true)
        page = pages.first unless pages.blank?
      end  
    end

    # Indicates if the page is used as a mount point for a public-facing
    # controller, e.g. a blog, message board etc.
    def rewrite_required?
      self.description.rewrite_required?
    end
    
    # Takes a path and rewrites it to point at an alternate route. The idea
    # being that this path points to a controller.
    def generate_rewrite_path(path) 
      path.gsub(current_localization.path, self.description.rewrite_route)
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
    # TODO Write spec for it
    def load_localization(locale = nil)
      @current_localization = localizations.where("locale_id = ? AND path LIKE ?", locale.id, "#{path}%").first 
    end

    def home=(state)
      write_attribute(:home, state)
      @home_updated = state
    end
    
    def self.home_page
      Page.find( :first ,  :conditions => [ "home = ? " , true ] )
    end
    
    def self.home_page_name
      home_temp = self.home_page
      if home_temp.blank?
        "Not Selected"
      else
        home_temp.name
      end
    end
    
    # if page type is not redirection.
    # then create default view files for all localzations of the page. 
    # file will be created in host appliation/app/views/pages/template_name.locale-slug.html.haml
    def create_default_template_file
      unless self.description.redirection_required?
        self.localizations.each do |page_localization|
          file_path = File.join(Rails.root, "app", "views" , "pages" , "#{self.view}.#{page_localization.locale.slug}.html.haml"  )
          unless File.exists?(file_path)
            file = File.new(file_path, "w")
        
            page_localization.contents.each do |content|
              file.puts("= render_content_for(:#{content.section_name})")
            end
            file.close
          end  
        end  
      end  
    end
    
        
    private

      

      # Checks to see if this page has been set as the homepage. If it has, we 
      # then go and 
      def check_for_home_update
        if @home_updated && @home_updated == true
          previous_home = Page.find( :first ,  :conditions => [ "home = ? AND id <> ? " , true ,self.id ] )
          previous_home.update_attributes(:home => false) if previous_home
        end
      end
    
  end
end


