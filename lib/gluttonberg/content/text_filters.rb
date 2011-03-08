module Gluttonberg
  module Content
    # The text filters module is used to extend Textile in a sneaky way. Within
    # any textual content in the site, users can use custom syntax for inserting
    # additional content. Typically this is used with textile, but will work 
    # inside of any text.
    #
    # The actual filters themselves are implemented as Merb parts. This gives 
    # them access to all the lovely filtering and rendering found in controllers.
    #
    # Parts can be turned into a filter by including the module 
    # Gluttonberg::TextFilters::PartMixin and then calling the is_text_filter
    # declaration.
    module TextFilters
      @@filters = {}
      
      # Returns all registered filters as a hash, keyed to the filter name.
      def self.all
        @@filters.values
      end
      
      # Get a specific filter by name.
      def self.get(name)
        @@filters[name.to_sym]
      end
      
      # Register a part controller as a filter. Generally doesn’t need to be 
      # called, since the is_text_filter declaration calls this under the hood.
      def self.register(name, klass)
        @@filters[name.to_sym] = klass
      end
      
      module PartMixin
        # A declaration for defining this part controller as a text filter.
        def is_text_filter(name)
          Gluttonberg::Content::TextFilters.register(name, self)
        end
      end
      
      module Helpers
        # This replaces each instance of our {{}} syntax with the results of 
        # calling a matching filter. The notation breaks down as class/action/id
        #
        #   {{movies/summary/3}}
        #
        def filter_text(text)
          if text
            text.gsub(%r{(<p>)?\{\{\S+\}\}(</p>)?}) do |match|
              extract = match.match(/(\w+)\/(\w+)\/(\w+)/)
              klass = Gluttonberg::Content::TextFilters.get(extract[1])
              # Now actually call the part. It's return value will be used as the 
              # replacement text in the gsub.
              part klass => extract[2].to_sym, :id => extract[3]
            end
          end
        end
      end
      
    end #TextFilters
  end # Content
end # Gluttonberg

