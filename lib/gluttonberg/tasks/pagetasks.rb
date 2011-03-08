namespace :slices do
  namespace :gluttonberg do 
    desc "Set or reset the cached depths on pages"
    task :set_page_depths => :merb_env do
      pages = Gluttonberg::Page.all(:parent_id => nil)
      pages.each { |page| page.set_depth!(0) }
    end
    
    desc "Convert all existing RichTextContent into HtmlContent"
    task :convert_rich_text_into_html_contents => :merb_env do
      Gluttonberg::RichTextContent.convert_to_html_content
    end

    desc "Generate localization records for all pages"
    task :generate_localizations_for_all_pages => :merb_env do
      Gluttonberg::Page.generate_localizations_for_all_pages
    end
    
    desc "Generate default dialect (en) and locale (au)"
    task :generate_default_dialect_and_locale => :merb_env do
      dialect = Gluttonberg::Dialect.create( :code => "en" , :name => "English" , :default => true)
      locale = Gluttonberg::Locale.new( :slug => "au" , :name => "Australia" , :default => true)      
      locale.dialect_ids = [dialect.id]
      locale.save!
    end
    
  end
end