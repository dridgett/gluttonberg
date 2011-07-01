class Flag < ActiveRecord::Base
  # serialize :flag, Symbol
  belongs_to :flaggable, :polymorphic => true

  # This will contain the names of all models that can_be_flagged
  cattr_accessor :flaggable_models
  
  # This line is dynamically generated when you call "can_flag" in your user/account model.
  # It assumes that content is owned by the same class as flaggers.
  # belongs_to :owner, :through => :flaggable, :class_name => ??

  # This is set dynamically in the plugin.
  # define "can_flag" in your user/account model.
  # belongs_to :user

  validates_presence_of :flaggable_id, :flaggable_type

  # requires all your content to have a user_id.  if not, then
  validates_presence_of :flaggable_user_id, :on => :create, 
    # :message => "error - your content must be owned by a user.",
    :if => Proc.new { |c| c.flaggable and c.flaggable.user_id }

  # A user can flag a specific flaggable with a specific flag once
  validates_uniqueness_of :user_id, :scope => [:flaggable_id, :flaggable_type]

  after_create :callback_flaggable
  # Pings the 'after_flagged' callback in the content model, if it exists.
  def callback_flaggable
    flaggable.callback :after_flagged
  end
  
  before_validation :set_owner_id , :on => :create 
  def set_owner_id
    self.flaggable_user_id = flaggable.user_id
  end
  
  validates_each :reason do |record,attr,value|
    record.errors.add(attr, "don't include '#{value}' as an option") if value and !record.flaggable.reasons.include?(value.to_sym)
  end
  
  scope :all_approved, :conditions => { :approved => true }
  scope :all_pending, :conditions => { :moderation_required => true }
  scope :all_rejected, :conditions => { :approved => false , :moderation_required => false }

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