module Gluttonberg
  class CommentSubscription < ActiveRecord::Base
    set_table_name "gb_comment_subscriptions"
    
    def self.notify_subscribers_of(article , comment)
      subscribers = self.find(:all , :conditions => {:article_id => article.id})
      subscribers.each do |subscriber|
        unless subscriber.author_email == comment.writer_email
          Notifier.delay.comment_notification(subscriber , article , comment ) #.deliver # its using delayed job but i am setting sent time immediately
          comment.update_attributes( :notification_sent_at => Time.now)
        end
      end
    end    
  end
end