
# *****
# LINKS
# *****
# extends the link textile markup to accept urls in the format of
#
#   asset:<id>
#   asset:<id>/thumb
#   asset:<id>/preview
#
#   where <id> is the id of a Gluttonberg::Asset object
#
#   the url is then replaced with the URL to the assets file. if the
#   thumb modifier is used then the url is the the assets thumbnail image,
#   if the preview modifier is used the url is to the assets large thumb image.
#
#   e.g.
#
#   irb> RedCloth.new('"file":asset:4').to_html
#   => "<p><a href=\"/assets/483e126734ca87ebdede76ac02e16438687aeca6/image.jpg\">file</a></p>"
#
#   irb> RedCloth.new('"file":asset:4/preview').to_html
#   => "<p><a href=\"/assets/483e126734ca87ebdede76ac02e16438687aeca6/_thumb_large.jpg\">file</a></p>"
#
# ******
# IMAGES
# ******
# extends the image textile markup to accept urls in the format of
#
#   asset:<id>
#   asset:<id>/thumb
#   asset:<id>/preview
#
#   where <id> is the id of a Gluttonberg::Asset object
#
#   the url is then replaced with the URL to the assets file. if the
#   thumb modifier is used then the url is the the assets thumbnail image,
#   if the preview modifier is used the url is to the assets large thumb image.
#
#   e.g.
#
#   irb> RedCloth.new('!asset:4!').to_html
#   => "<p><img src=\"/assets/483e126734ca87ebdede76ac02e16438687aeca6/image.jpg\" alt=\"\" /></p>"
#
#   irb> RedCloth.new('!asset:4/thumb!:asset:4').to_html
#   => "<p><a href=\"/assets/483e126734ca87ebdede76ac02e16438687aeca6/image.jpg\"><img src=\"/assets/483e126734ca87ebdede76ac02e16438687aeca6/_thumb_small.jpg\" alt=\"\" /></a></p>"
#

module RedClothHelpers
  #alias_method :original_link, :link

  def link(opts)
    opts[:href] = asset_patch_href(opts[:href])
    original_link(opts)
  end

  #alias_method :original_image, :image

  def image(opts)
    opts[:src] = asset_patch_href(opts[:src])
    opts[:href] = asset_patch_href(opts[:href]) if opts[:href]
    original_image(opts)
  end

  def asset_patch_href(href)
    result_href = href

    r = /(^asset:)(.[^\/]*)(\/(.*))?$/.match(href.downcase)
    if r then
      # r[0] = entire matched string
      # r[1] = asset id
      # r[4] = parameter passed

      # it's an asset link so get the number
      asset_id = r[2]
      param = r[4]
      asset = Gluttonberg::Asset.get(asset_id)
      if asset then
        if param and asset.url_for(param.to_sym)
         result_href = asset.url_for(param.to_sym)
       else
         result_href = asset.url
       end
      end
    end
    result_href
  end
end
