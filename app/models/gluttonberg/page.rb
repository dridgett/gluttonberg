module Gluttonberg
  class Page < ActiveRecord::Base
    has_many :localizations, :class_name => "Gluttonberg::PageLocalization"
    
    has_many :children, :class_name => "Gluttonberg::Page", :foreign_key => :parent_id, :order => 'position asc'
    
    set_table_name "gluttonberg_pages"
    
    
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
    
  end
end

