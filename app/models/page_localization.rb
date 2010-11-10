class PageLocalization < ActiveRecord::Base
  belongs_to :page
  acts_as_versioned
  
end
