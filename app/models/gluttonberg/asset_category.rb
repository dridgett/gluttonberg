module Gluttonberg
  class AssetCategory < ActiveRecord::Base
      set_table_name "gb_asset_categories"
      has_many :asset_types , :class_name => "AssetType"
      has_many :assets, :through => :asset_types
    
      validates_uniqueness_of :name
      validates_presence_of :name

      def self.method_missing(methId, *args)
        method_info = methId.id2name.split('_')
        if method_info.length == 2 then
          if method_info[1] == 'category' then
            cat_name = method_info[0]
            if cat_name then
              return find(:first , :conditions => "name = '#{cat_name}'")
            end
          end
        end
      end

      def self.build_defaults
        # Ensure the default categories exist in the database.
        ensure_exists('audio', false)
        ensure_exists('image', false)
        ensure_exists('video', false)    
        ensure_exists(Library::UNCATEGORISED_CATEGORY, true)
      end
    
    

      private

      def self.ensure_exists(name, unknown)
        cat = find(:first , :conditions => "name = '#{name}'")
        if cat then
          cat.unknown = unknown
          cat.save
        else
          cat = create(:name => name, :unknown => unknown)        
        end
      end

  end
end