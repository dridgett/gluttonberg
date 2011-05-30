module Gluttonberg
  class Comment < ActiveRecord::Base
    set_table_name "gb_comments"
    
    belongs_to :commentable, :polymorphic => true
    belongs_to :article
    belongs_to :author, :class_name => "User"
    
    before_save :init_moderation
    after_save :send_notifications_if_needed
    
    scope :all_approved, :conditions => { :approved => true }
    scope :all_pending, :conditions => { :moderation_required => true }
    scope :all_rejected, :conditions => { :approved => false , :moderation_required => false }
    
    attr_accessor :subscribe_to_comments , :blog_slug
    
    def moderate(params)
        if params == "approve"
          update_attributes(:moderation_required => false, :approved => true)
        elsif params == "disapprove"
          update_attributes(:moderation_required => false, :approved => false)
        else
          #error
        end
    end
    
    # these are helper methods for comment. 
    def writer_email
      if self.author_email
        self.author_email
      elsif author
        author.email
      end  
    end
    
    def writer_name
      if self.author_name
        self.author_name
      elsif author
        author.name
      end  
    end
    
    def approved=(val)
      @approve_updated = !self.moderation_required && val && self.notification_sent_at.blank? #just got approved
      write_attribute(:approved, val)
    end
    
    protected
      def init_moderation
        if commentable.has_attribute?(:moderation_required)
          if Blog.find(:first , :conditions => { :slug => blog_slug }).moderation_required == false
            self.approved = true
            write_attribute(:moderation_required, false)
          end
        end  
        true
      end 
    
      def send_notifications_if_needed        
        if @approve_updated == true
          @approve_updated = false
          CommentSubscription.notify_subscribers_of(self.commentable , self)
        end
      end
    
  end
end