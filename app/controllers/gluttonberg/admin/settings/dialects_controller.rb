module Gluttonberg
  module  Admin
    module Settings
      class DialectsController < Gluttonberg::Admin::ApplicationController
        

        before_filter :find_dialect, :only => [:delete, :edit, :update, :destroy]

        def index
          @dialects = Dialect.all #_for_user(session.user)
        end

        def new
          @dialect = Dialect.new
        end

        def edit
        end

        # def delete
        #          display_delete_confirmation(
        #            :title      => "Delete “#{@dialect.name}” dialect?",
        #            :action     => slice_url(:gluttonberg, :dialect, @dialect),
        #            :return_url => slice_url(:gluttonberg, :dialects)
        #          )
        #        end

        def create
          @dialect = Dialect.new(params["gluttonberg_dialect"])
          #@dialect.user_id = session.user.id
          if @dialect.save
            redirect_to admin_dialects_path
          else
            render :new
          end
        end

        def update
          if @dialect.update_attributes(params["gluttonberg_dialect"]) || !@dialect.dirty?
            redirect_to admin_dialects_path
          else
            render :edit
          end
        end

        def destroy
          if @dialect.destroy
            redirect_to admin_dialects_path
          else
            raise BadRequest
          end
        end

        private

        def find_dialect
          @dialect = Dialect.find(params[:id]) #Dialect.get_for_user(session.user , params[:id])
          raise NotFound unless @dialect
        end

      end#class
    end  
  end
end