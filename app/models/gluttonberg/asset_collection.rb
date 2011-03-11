module Gluttonberg
  class AssetCollection < ActiveRecord::Base
    
      has_and_belongs_to_many :assets, :class_name => "Asset"
      validates_uniqueness_of :name
      validates_presence_of :name
        

  end
end  