module Gluttonberg
  class Member < ActiveRecord::Base
  
    set_table_name "gb_members"
    
    has_and_belongs_to_many :groups, :class_name => "Group" , :join_table => "gb_groups_members"
    has_attached_file :image, :styles => { :profile => ["600x600"], :thumb => ["142x95#"] , :thumb_for_backend => ["100x75#"]}
    
  
    validates_presence_of :first_name , :email 
    attr_accessor :return_url , :term_and_conditions
    
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
      MemberNotifier.deliver_password_reset_instructions(self.id)  
    end
    
    def groups_name
      unless groups.blank?
        groups.map{|g| g.name}.join(", ")
      else
        ""  
      end
    end
    
    def self.enable_members
      if Rails.configuration.enable_members == true || Rails.configuration.enable_members.kind_of?(Hash)
        true
      else
        false
      end  
    end
    
    def self.does_email_verification_required
      if Rails.configuration.enable_members == true
        true
      elsif Rails.configuration.enable_members.kind_of? Hash
        if Rails.configuration.enable_members.has_key?(:email_verification)
          Rails.configuration.enable_members[:email_verification]
        else
          true
        end    
      else
        false
      end  
    end
    
    def self.generateRandomString(length=10)
      chars = ("A".."Z").to_a + ("0".."9").to_a
      similar_chars = %w{ i I 1 0 O o 5 S s }
      chars.delete_if {|x| similar_chars.include? x} 
      newpass = ""
      1.upto(length) { |i| newpass << chars[rand(chars.size-1)] }
      newpass
    end
    
    def does_member_have_access_to_the_page?( page)
      self.have_group?(page.groups)
    end
    
    def have_group?(groups)
      if groups.find_all{|g| self.group_ids.include?(g.id)  }.blank?
        false
      else
        true
      end
    end
    
  end
end  