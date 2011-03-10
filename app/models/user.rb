class User < ActiveRecord::Base
  
  acts_as_authentic do |c|
    c.login_field = "email"
  end
  
  def full_name
    self.first_name = "" if self.first_name.blank?
    self.last_name = "" if self.last_name.blank?
    self.first_name + " " + self.last_name
  end
  
end