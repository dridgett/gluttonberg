module Gluttonberg
  class PageLocalization < ActiveRecord::Base
    belongs_to :page, :class_name => "Gluttonberg::Page"
    belongs_to :dialect
    belongs_to :locale
    set_table_name "gb_page_localizations"
    
    #acts_as_versioned
    
    #associations with dynamic contentLocalization classes. To make sure these classes are
    # created and loaded I am calling those classes before that.
    # this helps me in development mode where classes reloads on each page request
    has_many :html_content_localizations , :class_name => "Gluttonberg::HtmlContentLocalization" , :dependent => :destroy 
    has_many :plain_text_content_localizations , :class_name => "Gluttonberg::PlainTextContentLocalization" , :dependent => :destroy 

    Gluttonberg::Content.localizations.each do |assoc, klass|
      has_many  assoc, :class_name => klass.to_s 
    end
    
    after_save :update_content_localizations
    attr_accessor :paths_need_recaching, :content_needs_saving

    # Write an explicit setter for the slug so we can check it’s not a blank 
    # value. This stops it being overwritten with an empty string.
    def slug=(new_slug)
      write_attribute(:slug, new_slug) unless new_slug.blank?
    end

    # Returns an array of content localizations
    def contents
      @contents ||= begin
        # First collect the localized content
        contents_data = Gluttonberg::Content.localization_associations.inject([]) do |memo, assoc|
          memo += send(assoc).all
        end        
        # Then grab the content that belongs directly to the page
        Gluttonberg::Content.non_localized_associations.inject(contents_data) do |memo, assoc|
          contents_data += page.send(assoc).all
        end
        contents_data
      end      
      
      # this is kind of hack. For some reasons in development mode, image contents are duplicated multiple times
      @contents.uniq! 
      @contents 
    end
    
    # Updates each localized content record and checks their validity
    def contents=(params)
      self.content_needs_saving = true
      contents.each do |content|
        update = params[content.association_name][content.id.to_s]
        content.attributes = update if update
      end
      #all_valid?
    end

    def paths_need_recaching?
      @paths_need_recaching
    end

    def name_and_code
      "#{name} (#{locale.name}/#{dialect.code})"
    end
    
    # Forces the localization to regenerate it's full path. It will firstly
    # look to see if there is a parent page that it need to derive the path
    # prefix from. Otherwise it will just use the slug, with a fall-back
    # to it's page's default.
    def regenerate_path
      page.reload #forcing that do not take cached page object
      if page.parent_id
        localization = page.parent.localizations.find(:first,
          :conditions => {
            :locale_id        => locale_id, 
            :dialect_id       => dialect_id
          }  
        )
        
        new_path = "#{localization.path}/#{slug || page.slug}"
      else
        new_path = "#{slug || page.slug}"
      end
      write_attribute(:path, new_path)
    end
    
    # Regenerates and saves the path to this localization.
    def regenerate_path!
      regenerate_path
      save
    end
    
    private
    
      def update_content_localizations
        contents.each { |c| c.save } if self.content_needs_saving
      end
    
    
  end
end

