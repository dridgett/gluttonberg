# encoding: utf-8

module Gluttonberg
  module  Admin
    module Settings
      class LocalesController < Gluttonberg::Admin::BaseController
        before_filter :find_locale, :only => [:delete, :edit, :update, :destroy]
        before_filter :require_super_admin_user
        
        def index
          @locales = Locale.all
        end

        def new
          @locale   = Locale.new
        end

        def edit
        end

        def delete
          display_delete_confirmation(
            :title      => "Delete “#{@locale.name}” locale?",
            :url        => admin_locale_path(@locale),
            :return_url => admin_locales_path , 
            :warning    => "Dependent page localizations of this locale will be also deleted."
          )        
        end

        def create
          @locale = Locale.new(params["gluttonberg_locale"])
          if @locale.save
            redirect_to admin_locales_path
          else
            render :new
          end
        end

        def update
          if @locale.update_attributes(params["gluttonberg_locale"]) || !@locale.dirty?
            redirect_to admin_locales_path
          else
            render :edit
          end
        end

        def destroy
       
          if @locale.destroy
            redirect_to admin_locales_path
          else
            raise ActiveResource::ServerError
          end
        end

        private

      
       def find_locale
          @locale = Locale.find(params[:id])
          raise ActiveRecord::RecordNotFound  unless @locale
        end
      
      end
    end
  end
end
