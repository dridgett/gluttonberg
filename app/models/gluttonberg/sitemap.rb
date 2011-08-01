module Gluttonberg
  class Sitemap
    @@links = {}
    
    def self.add(group , link)
      unless @@links.has_key?(group)
        @@links[group] = [link]
      else
        @@links[group] << link
        @@links[group] = @@links[group].uniq
      end
      @@links
    end
  
    def self.links
      @@links
    end
  
  
  end
end  