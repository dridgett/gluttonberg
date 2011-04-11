# encoding: utf-8

module Gluttonberg
  module  Admin
    module Settings
      class LocalesController < Gluttonberg::Admin::BaseController
        before_filter :find_locale, :only => [:delete, :edit, :update, :destroy]
      
        def index
          @locales = Locale.all
        end

        def new
          @locale   = Locale.new
          prepare_to_edit
        end

        def edit
          prepare_to_edit
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
            prepare_to_edit
            render :new
          end
        end

        def update
          if @locale.update_attributes(params["gluttonberg_locale"]) || !@locale.dirty?
            redirect_to admin_locales_path
          else
            prepare_to_edit
            render :edit
          end
        end

        def destroy
       
          if @locale.destroy
            redirect_to admin_locales_path
          else
            raise BadRequest
          end
        end

        private

        # Grabs the various model collections we need when editing or updating a record
        def prepare_to_edit
          unless @locale.new_record?
            @locales  = Locale.find(:all  , :conditions => ["id != ?" , params[:id] ] ,  :order => "name desc" )#_for_user(session.user, locale_opts)
          else
            @locales  = Locale.find(:all  ,  :order => "name desc" )
          end 
          @dialects = Dialect.all             
        end
      
       def find_locale
          @locale = Locale.find(params[:id])
          raise ActiveRecord::RecordNotFound  unless @locale
        end
      
      end
    end
  end
end
