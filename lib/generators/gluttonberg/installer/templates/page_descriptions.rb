Gluttonberg::PageDescription.add do

  page :home do
    label "Home"
    description "The homepage, with selected features."
    home true
    view "home"
    layout "application"    
  end
  
  page :newsletter do
    label "Newsletter"
    description "Newsletter Page"
    view "newsletter"
    layout "application"
    
    section :title do
      label "Title"
      type :plain_text_content
    end
    
    section :description do
      label "Description"
      type :html_content
    end
    
    section :image do
      label "Image"
      type  :image_content
    end
    
  end
  
  page :shows do
    label "Shows"
    description "Shows Page"
    
    rewrite_to 'shows'
    layout "application"
  end
  
  page :companies do
    label "Companies"
    description "Company Pages"
    
    rewrite_to 'companies'
  end
  
  page :venues do
    label "Venues"
    description "Venue Pages"
    
    rewrite_to 'venues'
  end
  
  page :reviews do
    label "Reviews"
    description "Review Pages"
    
    rewrite_to 'reviews'
  end
  
  page :news do
    label "News"
    description "News Page"
    layout "other"
    rewrite_to 'news'
  end
  
  page :subscribe do
    label "Subscribe"
    description "Subscription Page"
    
    rewrite_to 'subscribe'
  end
  
  page :about do
    label "About"
    description "About Page"
    view "about"
    layout "application"
    section :top_content do
      label "Content"
      type :html_content
    end
  end
  
  page :contact do
    label "Contact"
    description "Contact Page"
    view "contact"
    layout "application"
    section :top_content do
      label "Content"
      type :html_content
    end
  end
  
  page :sitemap do
    label "Site Map"
    description "Site Map"
    view "sitemap"
    layout "application"
  end
        
end