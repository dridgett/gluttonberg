module Gluttonberg
  # This module mainly acts as container for configuration related to the
  # Gluttonberg templates.
  module Templates
    
    
    def self.editor_template_path(type)
      "/gluttonberg/admin/content/editors/#{type}"
    end
    
  end
end