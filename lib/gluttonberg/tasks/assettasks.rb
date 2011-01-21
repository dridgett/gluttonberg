namespace :slices do
  namespace :gluttonberg do 
    desc "Try and generate thumbnails for all assets"
    task :create_thumbnails => :merb_env do
      assets = Gluttonberg::Asset.all
      assets.each do |asset|
        p "thumb-nailing '#{asset.file_name}'  "
        asset.generate_image_thumb
        asset.save
      end
    end

    desc "Rebuild AssetType information and reassociate with existing Assets"
    task :rebuild_asset_types => :merb_env do
      Gluttonberg::Library.rebuild
    end
    
    
    
  end
  desc "Assign file_name as name of those asset whose name is null"
  task :generate_asset_names => :merb_env do
    Gluttonberg::Asset.generate_name
  end
  
end