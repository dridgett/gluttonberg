class VersionTables < ActiveRecord::Migration
  def self.up
    Page.create_versioned_table
    PageLocalization.create_versioned_table  
  end

  def self.down
    Page.drop_versioned_table
    PageLocalization.drop_versioned_table
  end
  
end
