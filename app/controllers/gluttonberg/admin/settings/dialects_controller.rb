# encoding: utf-8

module Gluttonberg
  module  Admin
    module Settings
      class DialectsController < Gluttonberg::Admin::BaseController
        before_filter :find_dialect, :only => [:delete, :edit, :update, :destroy]

        def index
          @dialects = Dialect.all
        end

        def new
          @dialect = Dialect.new
        end

        def edit
        end

        def delete
          display_delete_confirmation(
            :title      => "Delete “#{@dialect.name}” dialect?",
            :url        => admin_dialect_path(@dialect),
            :return_url => admin_dialects_path , 
            :warning    => "Dependent locale association of this dialect will be also deleted. Potentially it will result into deletion of page localizations."
          )
        end

        def create
          @dialect = Dialect.new(params["gluttonberg_dialect"])
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
            raise ActiveResource::ServerError
          end
        end

        private

        def find_dialect
          @dialect = Dialect.find(params[:id]) 
          raise ActiveRecord::RecordNotFound  unless @dialect
        end

      end#class
    end  
  end
end