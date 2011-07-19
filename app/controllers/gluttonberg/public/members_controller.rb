module Gluttonberg
  module Public
    class MembersController < Gluttonberg::Public::BaseController
  
      before_filter :require_user , :only => [ :edit, :update, :show ]
  
      def new
        @page_title = "Register"
        @member = Member.new
      end
  
      def create
        @member = Member.new(params[:member])
        @member.role = "member"
        @member.confirmation_key = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..24]
        if @member.save
          PublicNotifier.confirmation_instructions(@member.id).deliver
          flash[:notice] = "Please check your email for a confirmation."
          redirect_to root_path
        else
          @page_title = "Register"
          render :new
        end
      end
  
  
      def confirm
        @member = Member.where(:confirmation_key => params[:key]).first
        if @member
          @member.profile_confirmed = true
          @member.save
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
        PublicNotifier.confirmation_instructions(current_member.id).deliver if current_member && !current_member.profile_confirmed
        flash[:notice] = "Please check your email for a confirmation."
        redirect_to profile_url
      end
  
      def update
        @member = current_member
        if @member.update_attributes(params[:member])
          @member.completed_profile = true
          @member.save
          if params[:user][:return_url]
            redirect_to params[:member][:return_url]
          else
            redirect_to root_path
          end
        end
      end
  
      def show
        @member = current_member
      end
  
      def edit
        @member = current_member
        interesting_ideas_for_you(current_member)
      end
  
  
  
      protected
  
    end
  end
end