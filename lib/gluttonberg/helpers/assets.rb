module Gluttonberg
  module Helpers
    # A bunch of helpers to make sure Gluttonberg’s admin layout looks in the 
    # right directory assets — js, css, img etc.
    module Assets
      # Returns the path to the image directory
      def gluttonberg_image_path(*segments)
        gluttonberg_public_path_for(:image, *segments)
      end

      # Returns the path to the javascript directory
      def gluttonberg_javascript_path(*segments)
        gluttonberg_public_path_for(:javascript, *segments)
      end

      # Returns the path to the stylesheet directory
      def gluttonberg_stylesheet_path(*segments)
        gluttonberg_public_path_for(:stylesheet, *segments)
      end

      # Returns the path to the public directory, under which all the other
      # asset directories are located.
      def gluttonberg_public_path_for(type, *segments)
        ::Gluttonberg.public_path_for(type, *segments)
      end
    end # Assets
  end # Helpers
end # Gluttonberg

