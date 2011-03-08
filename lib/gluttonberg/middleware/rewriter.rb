module Gluttonberg
  module Middleware
    class Rewriter
      def initialize(app)
        @app = app
      end

      def call(env)
        path = env['PATH_INFO']

        unless path =~ /^#{Gluttonberg::Engine.config.admin_path}/
          page = Gluttonberg::PublicPage.get(path, env['gluttonberg.locale'])
          if page
            env['gluttonberg.page'] = page
            env['gluttonberg.path_info'] = path
            env['PATH_INFO'] = page.mount_path(path) if page.mount_point?
          end
        end

        @app.call(env)
      end
    end # Rewriter
  end # Middleware
end # Gluttonberg

