class Notifier < ActionMailer::Base
  
  default :from => "noreply@freerangefuture.com"
  default_url_options[:host] = "freerangefuture.com"
  
  def password_reset_instructions(user_id)
    user = User.find(user_id)
    setup_email
    @subject += "Password Reset Instructions"
    @recipients = user.email  
    @body[:edit_password_reset_url] = edit_admin_password_reset_url(user.perishable_token)
  end
  
  protected
  
    def setup_email
      @from        = "noreply@freerangefuture.com"
      @subject     = "[Gluttonberg] "
      @sent_on     = Time.now
      @content_type = "text/html"
    end
    
end