# encoding: utf-8
# Do not remove above encoding line utf-8, its required for ruby 1.9.2. We are using some special chars in this file.

module Gluttonberg
  class Page < ActiveRecord::Base
    
    has_many :localizations, :class_name => "Gluttonberg::PageLocalization"   , :dependent => :destroy 

    # Generate the associations for the block/content classes
    Content::Block.classes.each do |klass| 
      has_many klass.association_name, :class_name => klass.name, :dependent => :destroy
    end
    
    
    validates_presence_of :name , :description_name
    
    set_table_name "gb_pages"
   
    has_many :html_contents , :class_name => "Gluttonberg::HtmlContent" , :dependent => :destroy 
    has_many :image_contents , :class_name => "Gluttonberg::ImageContent" , :dependent => :destroy 
    has_many :plain_text_contents , :class_name => "Gluttonberg::PlainTextContent" , :dependent => :destroy 
    
    before_validation :slug_management
    after_save   :check_for_home_update

    is_drag_tree :scope => :parent_id, :flat => false , :order => "position"
    
    attr_accessor :current_localization, :dialect_id, :locale_id, :paths_need_recaching , :depths_need_recaching
    
    
    #acts_as_versioned :if_changed => [:name , :description_name ] , :limit  => 5
    # we can lock state column. reverting to old version may change publishing status back to draft

    # include Transitions
    #     include ActiveRecord::Transitions
    # 
    #     state_machine do
    #          state :draft # first one is initial state
    #          state :reviewed
    #          state :published
    # 
    #          event :published do
    #            transitions :to => :published, :from => [:reviewed] # send email to admin
    #          end
    #          event :reviewed do
    #            transitions :to => :reviewed, :from => [:draft ]
    #          end
    #          event :draft do
    #            transitions :to => :draft, :from => [:reviewed] # :published can add more as array
    #          end
    #      end
    
    
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
      if current_localization.navigation_label.blank?
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
      current_localization.path
    end
    

    # Returns a hash containing the paths to the page and layout templates.
    def template_paths(opts = {})
      {
        :page => Gluttonberg::Templates.template_for(:pages, view, opts), 
        :layout => Gluttonberg::Templates.template_for(:layout, layout, opts)
      }
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

    # This finder grabs the matching page and under the hood also grabs the 
    # relevant localization.
    #
    # FIXME: The way errors are raised here is ver nasty, needs fixing up 
    def self.first_with_localization(options)
      if options[:path] == "" || options[:path] == "index"
        options.delete(:path)
        page = Page.first(:home => true)
        return nil unless page
        localization = page.localizations.first(options)
        return nil unless localization
      else
        localization = PageLocalization.first(options)
        return nil unless localization
        page = localization.page
      end
      page.current_localization = localization
      page
    end
    
    # Returns the matching pages with their specified localizations preloaded
    def self.all_with_localization(conditions)
      l_conditions = extract_localization_conditions(conditions)
      all(conditions).each {|p| p.load_localization(l_conditions)}
    end

    # Returns the immediate children of this page, which the specified
    # localization preloaded.
    # TODO: Have this actually check the current mode
    def children_with_localization(conditions)
      l_conditions = self.class.extract_localization_conditions(conditions)
      children.all(conditions).each { |c| c.load_localization(l_conditions)}
    end
    
    # Load the matching localization as specified in the options
    def load_localization(conditions = {})
      # OMGWTFBBQ: I shouldn't have explicitly set the id in the conditions
      # like this, since I’m going through an association.
      conditions[:page_id] = id 
      @current_localization = PageLocalization.first(conditions) unless conditions.empty?
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
    
    private
    
    def self.extract_localization_conditions(opts)
      conditions = [:dialect, :locale].inject({}) do |memo, opt|
        memo[:"#{opt}_id"] = opts.delete(opt).id if opts[opt]
        memo
      end
    end
    
    
    
  end
end


