class Page < ActiveRecord::Base
  has_many :page_localizations
  acts_as_versioned :if_changed => [:name , :description_name ] , :limit  => 5
  # we can lock state column. reverting to old version may change publishing status back to draft
  
  include Transitions
  include ActiveRecord::Transitions

  state_machine do
       state :draft # first one is initial state
       state :reviewed
       state :published

       event :published do
         transitions :to => :published, :from => [:reviewed] # send email to admin
       end
       event :reviewed do
         transitions :to => :reviewed, :from => [:draft ]
       end
       event :draft do
         transitions :to => :draft, :from => [:reviewed] # :published can add more as array
       end
   end
  
end
