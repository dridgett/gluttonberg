module Gluttonberg
    class Help
      # Default help paths
      @@gluttonberg_help_path = "help"
    
      # first find help in engine, if it founds return true
      # otherwise find in application. 
      def self.help_available?(opts)
        status = help_available_in(:engine , opts)
        status ? status : help_available_in(:application , opts)
      end
      
      # find help file in 'where'. if its :application then look into application 
      # otherwise look in engine
      def self.help_available_in(where , opts)
        if where == :application
          dir = template_dir_in_application(opts)
        else
          dir = template_dir_in_engine(opts)
        end
        
        if dir
          Dir.glob(File.join(dir ,  "/*") ).each do |template|
            return true if template.match(opts[:page].to_s)
          end
        end
        false
      end
    
      def self.path_to_template(opts)
        dir = template_dir(opts)
        "#{dir}/#{opts[:page]}"
      end
    
      def self.template_dir(opts)        
        "#{@@gluttonberg_help_path}/#{opts[:controller]}"
      end
      
      def self.template_dir_in_engine(opts)
        File.join(Engine.root , "app/views" , template_dir(opts)   )
      end
      
      def self.template_dir_in_application(opts)
        File.join(Rails.root , "app/views" , template_dir(opts)   )
      end
      
    end
end
