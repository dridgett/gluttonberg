module Gluttonberg
  class Comment < ActiveRecord::Base
    set_table_name "gb_comments"
    
    belongs_to :commentable, :polymorphic => true
    belongs_to :article
    belongs_to :author, :class_name => "User"
    
    def moderate(params)
      if params == "approve"
        update_attributes(:moderation_required => false, :approved => true)
      elsif params == "disapprove"
        update_attributes(:moderation_required => false, :approved => false)
      else
        #error
      end
    end
    
  end
end