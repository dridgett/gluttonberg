module Gluttonberg
  module Admin
    module Content    
      class PagesController < Gluttonberg::Admin::BaseController
            
      

        drag_tree Page, :route_name => :admin_page_move , :auto_gen_route => false

        before_filter :find_page, :only => [:show, :edit, :delete, :update, :destroy]

        def index
          #@pages = Page.all_for_user(current_user , :parent_id => nil, :order => [:position.asc])
          @pages = Page.find(:all , :conditions => { :parent_id => nil } , :order => 'position' )
       
        end

        def show
          #@default_localization = @page.localizations.first(:dialect_id => Dialect.first_default.id , :locale_id => Locale.first_default.id)
        end
            
        def new
          #only_provides :html
          @page = Page.new
          @page_localization = PageLocalization.new
          prepare_to_edit
          #render
        end
       
        def edit
          prepare_to_edit
        end
       
        #       def delete
        #         display_delete_confirmation(
        #           :title      => "Delete “#{@page.name}” page?",
        #           :action     => slice_url(:page, @page),
        #           :return_url => slice_url(:page, @page)
        #         )
        #       end
        # 
        def create
          @page = Page.new(params["gluttonberg_page"])
          @page.user_id = current_user.id
          if @page.save
            redirect_to admin_page_url(@page)
          else
            prepare_to_edit
            render :new
          end
        end

        def update
          if @page.update_attributes(params["gluttonberg_page"]) # || !@page.dirty?
            redirect_to admin_page_url(@page)
          else
            raise BadRequest
          end
        end

        def destroy
          if @page.destroy
            redirect_to admin_pages_path
          else
            raise BadRequest
          end
        end

        private

        def prepare_to_edit
          # @pages      = params[:id] ? Page.all_for_user(session.user , :id.not => params[:id]) : Page.all
          #         @dialects   = Dialect.all
          #         @locales    = Locale.all
          #         @descriptions = []
          #         Gluttonberg::PageDescription.all.each do |name, desc|
          #             @descriptions << [ name ,desc[:label] ]
          #         end       
        
          @pages  = params[:id] ? Page.find(:all , :conditions => [ "id  != ? " , params[:id] ] ) : Page.all
          #@dialects   = Dialect.all
          #@locales    = Locale.all
          @descriptions = []
          Gluttonberg::PageDescription.all.each do |name, desc|
              @descriptions << [desc[:label], name]
          end
        
        end

        def find_page
          #@page = Page.get_for_user(session.user, params[:id])
          @page = Page.find( params[:id])
          raise NotFound unless @page
        end
      
        # Returns a collection of Locale/Dialect pairs that have not yet been used
        # with the specified page.
        def pending_localizations
          existing = @page.localizations.collect {|l| [l.locale_id, l.dialect_id]}
          pending = []
          dialects = Dialect.all
          Locale.all.each do |locale|
            dialects.each do |dialect|
              unless existing.include?([locale.id, dialect.id])
                pending << ["#{locale.id}-#{dialect.id}", "#{locale.name} - #{dialect.name}"]
              end
            end
          end
          pending
        end
      end
    end #content  
  end #admin
end  #gluttonberg
