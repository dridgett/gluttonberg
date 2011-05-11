class Ability
  include CanCan::Ability

  def initialize(user)
    
    user ||= User.new # guest user (not logged in)
    if user.super_admin?
      can :manage, :all
    elsif user.admin?
      can :manage, :all
      restricted_features_for_admin
    else
      can :manage, :all
      restricted_features_for_admin
      
      cannot :manage , Gluttonberg::User
      cannot :manage , Gluttonberg::Setting
      cannot :destroy , Gluttonberg::Asset
      
      #page roles
      cannot :change_home , Gluttonberg::Page
      cannot :destroy , Gluttonberg::Page
      cannot :reorder , Gluttonberg::Page
      #TODO can edit own profile
    end
    
  end
  
  def restricted_features_for_admin
    cannot :manage , Gluttonberg::Locale
    cannot :create_or_destroy , Gluttonberg::Setting
  end
end