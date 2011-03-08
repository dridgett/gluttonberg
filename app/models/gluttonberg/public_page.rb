module Gluttonberg
  class PublicPage < ActiveRecord::Base
    def self.columns
      @columns ||= []
    end
   
    def self.column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end
    
    column :name,             :string
    column :mountable,        :boolean
    column :controller_name,  :string
    column :slug,             :string
      
    def self.get(path, locale = nil)

    end
    
    # Returns a boolean indicating if this is a mount-point for a controller.
    # This is determined by a flag in the record and a specification of a 
    # controller to mount.
    def mount_point?
      
    end

    # Generates a URL which points to this controller. It will also add any
    # postfixes specified in the path argument.
    def controller_path(postfix = nil)
      if postfix
        File.join("/_public", controller, postfix)
      else
        File.join("/_public", controller)
      end
    end
  end
end

