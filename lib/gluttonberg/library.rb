library = Pathname(__FILE__).dirname.expand_path
require File.join(library, "library", "attachment_mixin")

module Gluttonberg
  # The library module encapsulates the few bits of functionality that lives 
  # outside of the library models and controllers. It contains some 
  # configuration details and is responsible for bootstrapping the various bits
  # of meta-data used when categorising uploaded assets.
  module Library
    UNCATEGORISED_CATEGORY = 'uncategorised'
      
    @@assets_root = nil
    
    # Is run when the slice is loaded. It makes sure that all the required 
    # directories for storing assets are in the public dir, creating them if
    # they are missing. It also stores the various paths so they can be 
    # retreived using the assets_dir method.
    def self.setup
      Merb.logger.info("Gluttonberg is checking for asset folder")
      @@assets_root = Merb.dir_for(:public) / "assets"
      FileUtils.mkdir(root) unless File.exists?(root) || File.symlink?(root)
    end
    
    # Returns the path to the directory where assets are stored.
    def self.root
      @@assets_root
    end

    # This method is mainly for administrative purposes. It will rebuild the 
    # table of asset types, then recategorise each asset.
    def self.rebuild
      Asset.clear_all_asset_types
      flush_asset_types
      build_default_asset_types
      Asset.refresh_all_asset_types
    end

    # Removes and re-adds all asset types.
    def self.flush_asset_types
      AssetType.all.each{|asset_type| asset_type.destroy}
      AssetMimeType.all.each{|asset_mime_type| asset_mime_type.destroy}
    end

    # Adds a the inbuilt asset types to the database.
    def self.build_default_asset_types
      # ensure that all the categories exist
      AssetCategory.build_defaults
      ensure_type('Unknown Image', 'image', AssetCategory.image_category)
      ensure_type('Unknown Video', 'video', AssetCategory.video_category)
      ensure_type('Unknown Audio', 'audio', AssetCategory.audio_category)
      ensure_type('Unknown Document', 'text', AssetCategory.document_category)
      ensure_type('Unknown Archive', 'archive', AssetCategory.archive_category)
      ensure_type('Unknown Binary', 'binary application', AssetCategory.binary_category)
      ensure_type('Unknown File',   'multi-part model message unknown', AssetCategory.uncategorised_category)

      ensure_type('Jpeg Image', 'image/jpeg image/pjpeg', AssetCategory.image_category)
      ensure_type('Gif Image', 'image/gif', AssetCategory.image_category)
      ensure_type('Png Image', 'image/png', AssetCategory.image_category)
      ensure_type('Tiff Image', 'image/tiff', AssetCategory.image_category)
      ensure_type('Adobe Photoshop Image', 'image/vnd.adobe.photoshop', AssetCategory.image_category)
      ensure_type('Autocad Image', 'image/vnd.dwg', AssetCategory.image_category)
      ensure_type('Autocad Image', 'image/vnd.dxf', AssetCategory.image_category)
      ensure_type('Icon Image', 'image/vnd.microsoft.icon', AssetCategory.image_category)
      ensure_type('Bitmap Image', 'image/x-bmp image/bmp image/x-win-bmp', AssetCategory.image_category)
      ensure_type('Paintshop Pro Image', 'image/x-paintshoppro', AssetCategory.image_category)
      ensure_type('Mobile Image (plb,psb,pvb)', 'application/vnd.3gpp.pic-bw-large application/vnd.3gpp.pic-bw-small application/vnd.3gpp.pic-bw-var', AssetCategory.image_category)

      ensure_type('Moile Audio (3gpp,3gpp2)', 'audio/3gpp audio/3gpp2', AssetCategory.audio_category)
      ensure_type('Dolby Digital Audio (ac3)', 'audio/ac3', AssetCategory.audio_category)
      ensure_type('Mpeg Audio (mpga,mp2,mp3,mp4,mpa)', 'audio/mpeg audio/mpeg4-generic audio/mp4 audio/mpa-robust', AssetCategory.audio_category) # @mpga,mp2,mp3
      ensure_type('Aiff Audio (aif,aifc,aiff)', 'audio/x-aiff', AssetCategory.audio_category)
      ensure_type('Midi Audio (mid,midi,kar)', 'audio/x-midi', AssetCategory.audio_category)
      ensure_type('Real Audio (rm,ram,ra)', 'audio/x-pn-realaudio audio/x-realaudio', AssetCategory.audio_category)
      ensure_type('Wav Audio (wav)', 'audio/x-wav', AssetCategory.audio_category)
      ensure_type('Ogg Vorbis Audio (ogg)', 'application/ogg', AssetCategory.audio_category)

      ensure_type('Mobile Video', 'video/3gpp video/3gpp-tt video/3gpp2', AssetCategory.video_category) #  @3gp,3gpp 'RFC3839,DRAFT:draft-gellens-mime-bucket
      ensure_type('Digital Video', 'video/DV', AssetCategory.video_category) #  RFC3189
      ensure_type('Compressed Video', 'application/mpeg4-iod-xmt application/mpeg4-iod application/mpeg4-generic application/mp4 video/MPV video/mpeg4-generic video/mpeg video/MP2T video/H261 video/H263 video/H263-1998 video/H263-2000 video/H264 video/MP1S video/MP2P', AssetCategory.video_category) #  RFC3555
      ensure_type('Jpeg Video', 'video/JPEG video/MJ2', AssetCategory.video_category) #  RFC3555
      ensure_type('Quicktime Video', 'video/quicktime', AssetCategory.video_category)
      ensure_type('Uncompressed Video', 'video/raw', AssetCategory.video_category)
      ensure_type('Mpeg Playlist (mxu,m4u)', 'video/vnd.mpegurl', AssetCategory.video_category)
      ensure_type('Avi Video (avi)', 'video/x-msvideo', AssetCategory.video_category)
      ensure_type('Flash Video', 'video/x-flv', AssetCategory.video_category)

      ensure_type('Generic Document', 'application/x-csh application/x-dvi application/oda application/pgp-encrypted application/pgp-keys application/pgp-signature', AssetCategory.document_category)
      ensure_type('Calendar Document', 'text/calendar text/x-vcalendar', AssetCategory.document_category)
      ensure_type('Cascading Syle Sheet Document (css)', 'text/css', AssetCategory.document_category)
      ensure_type('Comma Seperated Values Document (csv)', 'text/csv text/comma-separated-values', AssetCategory.document_category)
      ensure_type('Tab Seperated Values Text Document', 'text/tab-separated-values', AssetCategory.document_category)
      ensure_type('Web Document', 'text/html', AssetCategory.document_category)
      ensure_type('Plain Text Document', 'text/plain', AssetCategory.document_category)
      ensure_type('Rich Text Document', 'text/richtext text/rtf', AssetCategory.document_category)
      ensure_type('Sgml Document', 'text/sgml', AssetCategory.document_category)
      ensure_type('Wap Document', 'text/vnd.wap.wml text/vnd.wap.wmlscript', AssetCategory.document_category)
      ensure_type('XML Document', 'text/xml text/xml-external-parsed-entity', AssetCategory.document_category)
      ensure_type('V-Card Document (vcf)', 'text/x-vcard', AssetCategory.document_category)
      ensure_type('Apple Macintosh Document (hqx)', 'application/mac-binhex40', AssetCategory.document_category)      
      ensure_type('Adobe Acrobat Document (pdf)', 'application/pdf', AssetCategory.document_category)
      ensure_type('Microsoft Word Document (doc,dot)', 'application/msword application/word', AssetCategory.document_category)
      ensure_type('Microsoft Powerpoint Document (ppt,pps,pot)', 'application/vnd.ms-powerpoint application/powerpoint', AssetCategory.document_category)
      ensure_type('Microsoft Excel Document (xls,xlt)', 'application/vnd.ms-excel application/excel', AssetCategory.document_category)
      ensure_type('Microsoft Works Document', 'application/vnd.ms-works', AssetCategory.document_category)
      ensure_type('Microsoft Project Document (mpp)', 'application/vnd.ms-project', AssetCategory.document_category)
      ensure_type('Microsoft Visio Document (vsd,vst,vsw,vss)', 'application/vnd.visio', AssetCategory.document_category)
      ensure_type('HTML Help Document (chm)', 'application/x-chm', AssetCategory.document_category)

#  application/vnd.ms-artgalry @cil 'IANA,[Slawson]
#  application/vnd.ms-asf @asf 'IANA,[Fleischman]
#  application/vnd.ms-wpl @wpl :base64 'IANA,[Plastina]
#  application/vnd.ms-tnef :base64 'IANA,[Gill]
#  application/vnd.ms-fontobject 'IANA,[Scarborough]
#  application/vnd.ms-ims 'IANA,[Ledoux]
#  application/vnd.ms-lrm @lrm 'IANA,[Ledoux]
#  application/vnd.wordperfect @wpd 'IANA,[Scarborough]
#  application/vnd.xara 'IANA,[Matthewman]

#  application/atom+xml 'RFC4287
#  application/ecmascript 'DRAFT:draft-hoehrmann-script-types
#  application/http 'RFC2616
#  application/javascript 'DRAFT:draft-hoehrmann-script-types

#  application/postscript @ai,eps,ps :8bit 'RFC2045,RFC2046
#  application/rdf+xml @rdf 'RFC3870
#  application/rtf @rtf 'IANA,[Lindner]
#  application/vnd.3M.Post-it-Notes 'IANA,[O'Brien]
#  application/vnd.FloGraphIt 'IANA,[Floersch]
#  application/vnd.Kinar @kne,knp,sdf 'IANA,[Thakkar]
#  application/vnd.Quark.QuarkXPress @qxd,qxt,qwd,qwt,qxl,qxb :8bit 'IANA,[Scheidler]
#  application/vnd.adobe.xfdf @xfdf 'IANA,[Perelman]
#  application/vnd.apple.installer+xml 'IANA,[Bierman]
#  application/vnd.audiograph 'IANA,[Slusanschi]
#  application/vnd.autopackage 'IANA,[Hearn]
#  application/vnd.cups-postscript 'IANA,[Sweet]
#  application/vnd.cups-raster 'IANA,[Sweet]
#  application/vnd.cups-raw 'IANA,[Sweet]
#  application/vnd.curl @curl 'IANA,[Byrnes]
#  application/vnd.kde.karbon @karbon 'IANA,[Faure]
#  application/vnd.kde.kchart @chrt 'IANA,[Faure]
#  application/vnd.kde.kformula @kfo 'IANA,[Faure]
#  application/vnd.kde.kivio @flw 'IANA,[Faure]
#  application/vnd.kde.kontour @kon 'IANA,[Faure]
#  application/vnd.kde.kpresenter @kpr,kpt 'IANA,[Faure]
#  application/vnd.kde.kspread @ksp 'IANA,[Faure]
#  application/vnd.kde.kword @kwd,kwt 'IANA,[Faure]
#  application/vnd.lotus-1-2-3 @wks,123 'IANA,[Wattenberger]
#  application/vnd.lotus-notes 'IANA,[Laramie]
#  application/vnd.micrografx.flo @flo 'IANA,[Prevo]
#  application/vnd.micrografx.igx @igx 'IANA,[Prevo]
#  application/vnd.palm @prc,pdb,pqa,oprc :base64 'IANA,[Peacock]
#  application/vnd.powerbuilder6 'IANA,[Guy]
#  application/vnd.powerbuilder6-s 'IANA,[Guy]
#  application/vnd.powerbuilder7 'IANA,[Shilts]
#  application/vnd.powerbuilder7-s 'IANA,[Shilts]
#  application/vnd.powerbuilder75 'IANA,[Shilts]
#  application/vnd.powerbuilder75-s 'IANA,[Shilts]
#  application/wordperfect5.1 @wp5,wp 'IANA,[Lindner]
#  application/xhtml+xml @xhtml :8bit 'RFC3236
#  application/xml @xml :8bit 'RFC3023
#  application/xml-dtd :8bit 'RFC3023
#  application/xml-external-parsed-entity 'RFC3023
#  application/xmpp+xml 'RFC3923

#  application/x-latex @ltx,latex :8bit 'LTSW
#  application/x-mif @mif 'LTSW
#  application/x-rtf 'LTSW =use-instead:application/rtf
#  application/x-sh @sh 'LTSW
#  application/x-sv4cpio @sv4cpio :base64 'LTSW
#  application/x-sv4crc @sv4crc :base64 'LTSW
#  application/x-tcl @tcl :8bit 'LTSW
#  application/x-tex @tex :8bit
#  application/x-texinfo @texinfo,texi :8bit

#  application/acad 'LTSW
#  application/clariscad 'LTSW
#  application/drafting 'LTSW
#  application/dxf 'LTSW

# ARCHIVE TYPES
#  application/zip @zip :base64 'IANA,[Lindner]
#  application/x-compressed @z,Z :base64 'LTSW
#  application/x-gtar @gtar,tgz,tbz2,tbz :base64 'LTSW
#  application/x-gzip @gz :base64 'LTSW
#  application/x-tar @tar :base64 'LTSW
#  application/x-stuffit @sit :base64 'LTSW
#  application/vnd.ms-cab-compressed @cab 'IANA,[Scarborough]

# BINARY TYPES
#  application/octet-stream @bin,dms,lha,lzh,exe,class,ani,pgp :base64 'RFC2045,RFC2046
#  application/macbinary 'LTSW
#  mac:application/x-mac @bin :base64
#  application/x-java-archive @jar 'LTSW
#  application/x-java-jnlp-file @jnlp 'LTSW
#  application/x-java-serialized-object @ser 'LTSW
#  application/x-java-vm @class 'LTSW#
#
    end

    private
    
    # Makes sure the specified type exists in the DB, if it doesn’t it creates 
    # a new record.
    def self.ensure_type(name, mime_type, category)
      asset_type = AssetType.first(:name => name)
      if asset_type then
        asset_type.asset_category = category
      else
        asset_type = AssetType.new(:name => name, :asset_category => category)
      end
      mime_type.split(' ').each do |this_mime_type|
        asset_mime_type = AssetMimeType.new(:mime_type => this_mime_type)
        asset_type.asset_mime_types << asset_mime_type
        asset_mime_type.save
      end
      asset_type.save
    end
  end # Library
end # Gluttonberg
