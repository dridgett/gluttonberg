module Gluttonberg
 class Setting  < ActiveRecord::Base
   #include Gluttonberg::Authorizable
   set_table_name "gb_settings" 
   after_save  :update_settings_in_config
    
    def self.generate_settings(settings={})      
      settings.each do |key , val |
        obj = self.new(:name=> key , :category => val[0] , :row => val[1] , :delete_able => false , :help => val[2])
        obj.save!
      end  
    end  
    
    def self.generate_common_settings
      settings = {
        :title => [:meta_data , 0, "Website Title"], 
        :description => [:meta_data, 2 , "The Description will appear in search engine's result list."], 
        :keywords => [:meta_data, 1, "Please separate keywords with a comma."],
        :google_analytics => [:google_analytics, 3, "Google Analytics ID"]
      }
      self.generate_settings(settings)
    end  
    
    def self.update_settings(settings={})
      settings.each do |key , val |
        obj = self.first(:name=> key)
        obj.value = val
        obj.save!
      end  
    end 
    
    def update_settings_in_config
      begin
        setting = self
        Engine.config.gluttonberg[setting.name.to_sym] = setting.value
      rescue => e
        Rails.logger.info e
      end
    end 

  end
end
