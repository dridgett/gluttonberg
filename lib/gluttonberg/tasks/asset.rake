require 'rubygems'

ASSET_LIBRARY_BASE_DIR = File.join(File.dirname(__FILE__), "../..")

namespace :gluttonberg do 
  namespace :library do 
    
    desc "Try and generate thumbnails for all assets"
    task :create_thumbnails => :environment do
      category = Gluttonberg::AssetCategory.find( :first , :conditions =>{  :name => "image" } )
      if category
        assets = category.assets #Asset.all
        assets.each do |asset|
          p "thumb-nailing '#{asset.file_name}'  "
          asset.generate_image_thumb
          asset.generate_proper_resolution
          asset.save
        end
      end  
    end

    desc "Rebuild AssetType information and reassociate with existing Assets"
    task :rebuild_asset_types => :environment do
      Gluttonberg::Library.rebuild
    end
  
    desc "Assign file_name as name of those asset whose name is null"
    task :generate_asset_names => :environment do
      Gluttonberg::Asset.generate_name
    end
  
    desc "Make assets from files in bulks folder"
    task :generate_asset_from_bulks_folder => :environment do
      Gluttonberg::Asset.create_assets_from_ftp
    end
  
    desc "Update assets synopsis through csv"
    task :update_assets_synopsis_from_csv => :environment do
      Gluttonberg::Asset.update_assets_synopsis_from_csv
    end
  
    
  
    # desc "regenerate duration of video assets"
    #   task :regenerate_video_assets => :environment do
    #       assets = Asset.find(:all, :conditions => {:type => "Video"})
    #       assets.each do |asset|
    #         begin
    #           puts "Starting to encode #{command}"
    #           transcoder = RVideo::Transcoder.new
    #           result = transcoder.execute(command, options)
    #           #asset.duration = transcoder.processed.duration
    #           asset.save
    #         rescue => e
    #           puts "Unable to transcode file: #{e.class} - #{e.message}"
    #         end
    #       end  
    #   end
  
    desc "regenerate all video assets"
    task :regenerate_video_assets => :environment do
    
      def save_asset_to(asset)
        Rails.root.to_s + "/public" + asset.asset_folder_path
      end
    
      assets = Asset.find(:all, :conditions => {:type => "Video"})
      assets.each do |asset|
        result =  begin
                  commands = [
                    "ffmpeg -i $file$ -b 1500k -vcodec libx264 -vpre slow -vpre baseline -g 30 -y #{save_asset_to(asset)}/#{asset.filename_without_extension}_hd720.mp4",
                    "ffmpeg -i $file$ -b 600k -vcodec libx264 -vpre slow -vpre baseline -g 30 -y #{save_asset_to(asset)}/#{asset.filename_without_extension}_hd480.mp4",
                    "ffmpeg -i $file$ -b 1536000 -vcodec libvpx -acodec libvorbis -ab 160000 -f webm -g 30 -y #{save_asset_to(asset)}/#{asset.filename_without_extension}_hd720.webm",
                    "ffmpeg -i $file$ -b 614400 -vcodec libvpx -acodec libvorbis -ab 160000 -f webm -g 30 -y #{save_asset_to(asset)}/#{asset.filename_without_extension}_hd480.webm",
                    "ffmpeg -i $file$ -b 1500k -vcodec libtheora -acodec libvorbis -ab 160000 -g 30 -y #{save_asset_to(asset)}/#{asset.filename_without_extension}_hd720.ogv",
                    "ffmpeg -i $file$ -b 600k -vcodec libtheora -acodec libvorbis -ab 160000 -g 30 -y #{save_asset_to(asset)}/#{asset.filename_without_extension}_hd480.ogv"
                    ]
                  options = {:file => asset.absolute_file_path}
                  commands.each do |command|
                    begin
                      puts "Starting to encode #{command}"
                      transcoder = RVideo::Transcoder.new
                      result = transcoder.execute(command, options)
                      #asset.duration = transcoder.processed.duration
                      asset.processed = true
                      asset.save
                    rescue => e
                      asset.processed = true
                      #asset.error = true
                      asset.save
                      puts "Unable to transcode file: #{e.class} - #{e.message}"
                    end
                  end
                                
                  # asset.processed = false
                  #                 asset.error = false
                  #                 asset.save
                  #                 processed_file = Pathname.new("#{Rails.root}/#{asset.directory}/processed_#{asset.filename_without_extension}.mp4")
                  #                 FileUtils.rm(processed_file) if processed_file.exist?
                  #                 transcoder = RVideo::Transcoder.new
                  #                 command = "ffmpeg -i $input_file$ -acodec libfaac -ab 96k -vcodec libx264 -vpre slow -b 1600k -threads 0 $output_file$"
                  #                 options = {:input_file => asset.absolute_file_path, :output_file => "#{Rails.root}/#{asset.directory}/processed_#{asset.filename_without_extension}.mp4"}
                  #                 result = transcoder.execute(command, options)
                  #                 if result == true
                  #                   asset.duration = transcoder.processed.duration
                  #                   asset.processed = true
                  #                   asset.save
                  #                 else
                  #                   asset.error = true
                  #                   asset.save
                  #                 end
                rescue => e2
                  asset.error = true
                  asset.save
                  puts puts "loop exception: #{e2.class} - #{e2.message}"
                end
        print result ? "." : "x"; $stdout.flush
      end
      puts "Completed!"
    end
  
  
  end  
end  