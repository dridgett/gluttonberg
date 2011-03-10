module Gluttonberg
  class RichTextContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
            
    is_localized do
      property :text,           Text
      
      before :save, :convert_textile_text_to_html
      
      is_textilized :text
    end
    
    def self.convert_to_html_content
      
      all_text_contents = self.all
      all_text_contents.each do |text_content|
        html_content = HtmlContent.create(:orphaned => text_content.orphaned , :section_name=> text_content.section_name , :page_id => text_content.page_id)
        text_content.localizations.each do |localization|
          new_localization = html_content.localizations.create(:parent => html_content, :page_localization_id => localization.page_localization_id , :text => localization.formatted_text)
          localization.destroy
        end
        text_content.destroy
      end
    end
  end
end