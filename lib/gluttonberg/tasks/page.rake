namespace :gluttonberg do 
  
  # reviewed by abdul on 29/03/2011
  desc "Set or reset the cached depths on pages"
  task :set_page_depths => :environment do
    pages = Gluttonberg::Page.find(:all , :conditions => { :parent_id => nil } )
    pages.each { |page| page.set_depth!(0) }
  end
  
  desc "Convert all existing RichTextContent into HtmlContent"
  task :convert_rich_text_into_html_contents => :environment do
    Gluttonberg::RichTextContent.convert_to_html_content
  end

  desc "Generate localization records for all pages"
  task :generate_localizations_for_all_pages => :environment do
    Gluttonberg::Page.generate_localizations_for_all_pages
  end
  
  # reviewed by abdul on 29/03/2011
  desc "Generate default dialect (en) and locale (au)"
  task :generate_default_dialect_and_locale => :environment do
    dialect = Gluttonberg::Dialect.create( :code => "en" , :name => "English" , :default => true)
    locale = Gluttonberg::Locale.new( :slug => "au" , :name => "Australia" , :default => true)      
    locale.dialect_ids = [dialect.id]
    locale.save!
  end
  
end
