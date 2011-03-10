module Gluttonberg
  module Content
    # A module for adding textile formatting to models. Just include this 
    # module, then for each field that you would like to textilize, just 
    # include it in the is_textilized declaration. Like so:
    #
    #   is_textilized, :summary, :body
    #
    module Textilized
      # The hook that adds the ivars, then includes/extends with the _real_ 
      # modules.
      def self.included(klass)
        klass.class_eval do
          class << self; attr_accessor :textilized_fields end
          extend ClassMethods
          include InstanceMethods
        end
      end
      
      module ClassMethods
        # The declaration for adding a field to the list of those to be 
        # formatted.
        def is_textilized(*fields)
          self.textilized_fields = {}
          fields.each do |field|
            self.textilized_fields[field] = :"formatted_#{field}"
            property :"formatted_#{field}", DataMapper::Types::Text, :writer => :private
          end
          before :save, :convert_textile_text_to_html
        end
      end
      
      module InstanceMethods
        private
        # The before filter called on save. This does the actual 
        # convertoranting of the textile to markup and stores it in the 
        # generated property.
        def convert_textile_text_to_html
          self.class.textilized_fields.each do |field, formatted_field|
            if attribute_dirty?(field) || (attribute_get(field) && attribute_get(formatted_field).nil?)
              attribute_set(formatted_field, RedCloth.new(attribute_get(field)).to_html)#.extend(::RedClothExtensions)
            end
          end
        end
      end
    end # Textilized
  end # Content
end # Gluttonberg
