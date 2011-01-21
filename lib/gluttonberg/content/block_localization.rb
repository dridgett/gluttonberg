module Gluttonberg
  module Content
    # The mixin used when generating a localization for content classes. It
    # adds the base properties — e.g. id — and associations. It also comes with
    # some convenience methods for accessing the associated section in a page.
    # 
    # These just defer to the parent class.
    module BlockLocalization
      def self.included(klass)
        klass.class_eval do
          class << self; attr_accessor :content_type, :association_name end
          
          property :id,         ::DataMapper::Types::Serial
          property :created_at, Time
          property :updated_at, Time

          belongs_to :page_localization
        end
      end
      
      def association_name
        self.class.association_name
      end
      
      def content_type
        self.class.content_type
      end
      
      def section_name
        parent.section[:name]
      end
      
      def section_label
        parent.section[:label] unless parent.blank?
      end
    end
  end
end
