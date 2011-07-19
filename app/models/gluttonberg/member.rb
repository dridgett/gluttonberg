module Gluttonberg
  class Member < ActiveRecord::Base
  
    set_table_name "gb_members"
    
    has_and_belongs_to_many :groups, :class_name => "Group" , :join_table => "gb_groups_members"
    has_attached_file :image, :styles => { :profile => ["600x600"], :thumb => ["142x95#"]}
    
  
    validates_presence_of :first_name , :email 
    
    attr_accessor :image_delete
    
  
    clean_html [:bio]
  
    acts_as_authentic do |c|
      c.session_class = MemberSession
      c.login_field = "email"
    end
  
    def full_name
      self.first_name = "" if self.first_name.blank?
      self.last_name = "" if self.last_name.blank?
      self.first_name + " " + self.last_name
    end
  
    def deliver_password_reset_instructions!  
      reset_perishable_token!
      Notifier.deliver_password_reset_instructions(self.id)  
    end
  end
end  