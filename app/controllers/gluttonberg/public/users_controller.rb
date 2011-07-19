class UsersController < ApplicationController
  skip_before_filter :check_profile_complete?
  
  before_filter :require_user , :only => [:complete , :edit, :update, :show , :ideas , :favourite_ideas]
  
  def new
    @page_title = "Register"
    @user = User.new
  end
  
  def postcode_list
    query = params[:term].strip
    ActiveRecord::Base.include_root_in_json = false
    @postcodes = PostCode.where("location LIKE '%#{query.upcase}%'").select("id , location || ' (' || code || ')' as value") 
    @postcodes.each_with_index do |p , index|
      @postcodes[index].value = p.value.titleize
    end
    render :json => @postcodes.to_json
  end
  
  def find_postcode
    query = params[:term].strip
    @postcode = PostCode.find(:first , :conditions => { :location => query.upcase})
    render :text => (@postcode.blank? ? "false" : @postcode.id.to_s) 
  end
  
  def postcode_verification
    query = params[:term]
    query = params[:live] if query.blank?
    query = params[:work] if query.blank?
    query = params[:play] if query.blank?
    unless query.blank?
      puts query.split("(")
      query = query.split("(").first.strip
      @postcode = PostCode.find(:first , :conditions => { :location => query.upcase})
    end
    render :text => (@postcode.blank? ? "false" : "true")
  end
  
  
  def create
    @user = User.new(params[:user])
    @user.role = "member"
    @user.confirmation_key = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..24]
    if @user.save
      PublicNotifier.confirmation_instructions(@user.id).deliver
      flash[:notice] = "Please check your email for a confirmation."
      redirect_to root_path
    else
      @page_title = "Register"
      find_live_work_play
      render :new
    end
  end
  
  def complete
    @user = current_user
    find_live_work_play
    @page_title = "Complete your profile"
  end
  
  def confirm
    @user = User.where(:confirmation_key => params[:key]).first
    if @user
      @user.profile_confirmed = true
      @user.save
      flash[:notice] = "Your registration is now complete."
      redirect_to root_url
    else
      flash[:notice] = "We're sorry, but we could not locate your account. " +
      "If you are having issues try copying and pasting the URL " +
      "from your email into your browser."
      redirect_to root_url
    end
  end
  
  def resend_confirmation
    PublicNotifier.confirmation_instructions(current_user.id).deliver if current_user && !current_user.profile_confirmed
    flash[:notice] = "Please check your email for a confirmation."
    redirect_to profile_url
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      @user.completed_profile = true
      @user.save
      if params[:user][:return_url]
        redirect_to params[:user][:return_url]
      else
        redirect_to root_path
      end
    else
      find_live_work_play
      render :complete
    end
  end
  
  def show
    @page_title = "#{current_user.full_name} profile"
    interesting_ideas_for_you(current_user)
    
    #calculations for graph statistics
    @chart1_your = Idea.user_total_commented_ideas(current_user)
    @chart1_others = Idea.total_commented_ideas - @chart1_your
    
    @chart2_your = Gluttonberg::Comment.where(:commentable_type => "Idea", :author_id => current_user.id ).length
    @chart2_others = Gluttonberg::Comment.where(:commentable_type => "Idea").length - @chart2_your
    
    @bar_chart_ideas = Idea.top_5_voted_ideas_of_the_user(current_user)
    @votes_bar_chart = @bar_chart_ideas.collect{|idea| sprintf("%5.2f",((idea.positive_voters.length.to_f / idea.votes.length.to_f) * 100))   }
    
    @favourited_bar_chart_ideas = Idea.top_5_favourited_ideas_of_the_user(current_user)
    @favourited_bar_chart = @favourited_bar_chart_ideas.collect{|idea|  idea.favourites.length   }
    @total_fav = 0
    @favourited_bar_chart.each do |f|
      @total_fav += f
    end
  end
  
  def edit
    @user = current_user
    find_live_work_play
    interesting_ideas_for_you(current_user)
  end
  
  def ideas
    @page_title = "#{current_user.full_name} ideas"
    @ideas = Idea.where(:user_id => current_user.id).find_all{|c| !c.inappropriate? }.paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')
    interesting_ideas_for_you(current_user)
  end
  
  def favourite_ideas
    @page_title = "#{current_user.full_name} ideas"
    @ideas = current_user.favourite_ideas.find_all{|c| !c.inappropriate? }.paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')
    interesting_ideas_for_you(current_user)
  end
  
  protected
  
    def interesting_ideas_for_you(current_user)
      themes = []
      current_user.ideas.each do |idea|
        idea.themes.each do |t|
          themes << t.name
        end
      end
      ii = Idea.joins(:themes).where("themes.name" => themes.uniq.map {|t|t}).order("votes_count DESC")
      @interesting_ideas = ii.uniq.find_all{|c| !c.inappropriate? }
    end
    
    def find_live_work_play
      unless @user.blank?
        live = PostCode.find(:first , :conditions => {:id => @user.live})
        @live = live.location.titleize unless live.blank?
        work = PostCode.find(:first , :conditions => {:id => @user.work})
        @work = work.location.titleize unless work.blank?
        play = PostCode.find(:first , :conditions => {:id => @user.play})
        @play = play.location.titleize unless play.blank?
      end  
    end
  
end