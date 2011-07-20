module Gluttonberg
  module Public
    class MemberSessionsController < Gluttonberg::Public::BaseController
      
      layout 'public'
      before_filter :is_members_enabled
      skip_before_filter :require_member, :only => [:new, :create]
      
      def new
        @member_session = MemberSession.new
      end
  
      def create
        @member_session = MemberSession.new(params[:member_session])
        if @member_session.save
          flash[:notice] = "Login successful!"
          redirect_back_or_default root_path
        else
          render :action => :new
        end
      end
  
      def destroy
        current_member_session.destroy
        flash[:notice] = "Logout successful!"
        redirect_back_or_default root_path
      end
    end
  end
end