module Gluttonberg
  module Middleware
    class Rewriter
      def initialize(app)
        @app = app
      end

      def call(env)
        path = env['PATH_INFO']
        # puts path
        #         
        #         current_request = ActionDispatch::Request.new(env)
        #         unless path.include?("restrict_site_access" )
        #           setting = Gluttonberg::Setting.get_setting("restrict_site_access")
        #           if !setting.blank? && current_request.cookie_jar[:restrict_site_access] != "allowed"
        #             redirect_to "/restrict_site_access?return_url=#{path}"
        #             #redirect_to restrict_site_access_path(:return_url => path)
        #             return
        #           end
        #         end
        
        unless path =~ /^#{Gluttonberg::Engine.config.admin_path}/ || path.start_with?("/stylesheets")  || path.start_with?("/javascripts") || path.start_with?("/images") ||  path.start_with?("/gluttonberg")   || path.start_with?("/asset") 
          page = Gluttonberg::Page.find_by_path(path, env['gluttonberg.locale'])
          unless page.blank?
            env['gluttonberg.page'] = page
            env['gluttonberg.path_info'] = path
            if page.rewrite_required?
              env['PATH_INFO'] = page.generate_rewrite_path(path) 
            else
              env['PATH_INFO'] = '/_public/page'
            end
          end
        end

        @app.call(env)
      end
    end # Rewriter
  end # Middleware
end # Gluttonberg
