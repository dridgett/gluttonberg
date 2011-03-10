module Gluttonberg
  module  Admin
    module Settings
      class LocalesController < ApplicationController
        include Gluttonberg::AdminControllerMixin
        layout 'gluttonberg'


        before_filter :find_locale, :only => [:delete, :edit, :update, :destroy]
      
        def index
          @locales = Locale.all#_for_user(session.user , :order => [:name.asc])
        end

        def new
          @locale   = Locale.new
          prepare_to_edit
        end

        def edit
          prepare_to_edit
        end

        # def delete
        #   only_provides :html
        #   display_delete_confirmation(
        #     :title      => "Delete the “#{@locale.name}” locale?",
        #     :action     => slice_url(:locale, @locale),
        #     :return_url => slice_url(:locales)
        #   )
        # end

        def create
          @locale = Locale.new(params["gluttonberg_locale"])
          #@locale.user_id = session.user.id
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
            @locales  = Locale.find(:all  , :conditions => ["id != ?" , id ] ,  :order => "name desc" )#_for_user(session.user, locale_opts)
          else
            @locales  = Locale.find(:all  ,  :order => "name desc" )
          end
          @dialects = Dialect.all#_for_user(session.user)        
        end
      
       def find_locale
          @locale = Locale.find(params[:id])#get_for_user(session.user , params[:id])
          raise NotFound unless @locale
        end
      
      end
    end
  end
end
