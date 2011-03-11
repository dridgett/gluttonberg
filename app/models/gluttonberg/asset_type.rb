module Gluttonberg
    #require 'action_controller/mime_types'
  require 'mime/types'  
  class AssetType < ActiveRecord::Base
    
      has_many    :assets , :class_name => "Asset"
      has_many    :asset_mime_types , :class_name => "AssetMimeType"
      belongs_to  :asset_category, :class_name => "AssetCategory"

      validates_uniqueness_of :name
      validates_presence_of :name

      # Take the reported mime-type and the file_name and return
      # the best AssetType to use for that file.
      def self.for_file(mime_type, file_name)
      
        mime_types = ::MIME::Types[mime_type]
            

        # if the supplied mime_type isn't recognised as aregistered or common one,
        # try and work out a suitable one from the file extension
        if mime_types.blank?
          mime_types = ::MIME::Types.type_for(file_name)
        end

        # OK, we really have no idea what this is
        if mime_types.empty?
          file_mime_type = mime_type
          file_base_type = mime_type.split('/').first
        else
          # multiple mime-types may be returned, but we only want to work with
          # one, so pick the first one
          file_mime_type = mime_types.first.content_type
          file_base_type = mime_types.first.raw_media_type
        end
      
        asset_mime_type = AssetMimeType.find(:first, :conditions => "mime_type = '#{file_mime_type}'")
      
        if asset_mime_type.nil? then
          asset_mime_type = AssetMimeType.find(:first, :conditions => "mime_type = '#{file_base_type}'")
          if asset_mime_type.nil? then
            # this is a completely unknown type, so default to unkown
            asset_mime_type = AssetMimeType.find( :first, :conditions => "mime_type = 'unknown'")
            if asset_mime_type.nil? then            
              # something went wrong, so just assign anything :-(
              return AssetType.first
            else
              return asset_mime_type.asset_type
            end
          else
            return asset_mime_type.asset_type
          end
        else
          return asset_mime_type.asset_type
        end
      end

      def self.build_defaults
        Library::build_default_asset_types
      end
  end
end