module Gluttonberg
  module Middleware
    class Rewriter
      def initialize(app)
        @app = app
      end

      def call(env)
        path = env['PATH_INFO']
        unless path =~ /^#{Gluttonberg::Engine.config.admin_path}/ || path.start_with?("/stylesheets")  || path.start_with?("/javascripts") || path.start_with?("/images") || path.start_with?("/asset") 
          page = Gluttonberg::Page.find_by_path(path, env['gluttonberg.locale'])
          if page
            env['gluttonberg.page'] = page
            env['gluttonberg.path_info'] = path
            if page.mount_point?
              env['PATH_INFO'] = page.mount_path(path) 
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