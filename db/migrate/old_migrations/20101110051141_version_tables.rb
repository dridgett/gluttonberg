class VersionTables < ActiveRecord::Migration
  def self.up
    #Gluttonberg::Page.create_versioned_table
    #Gluttonberg::PageLocalization.create_versioned_table  
  end

  def self.down
    #Gluttonberg::Page.drop_versioned_table
    #Gluttonberg::PageLocalization.drop_versioned_table
  end
  
end
