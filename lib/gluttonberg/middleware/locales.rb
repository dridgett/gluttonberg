module Gluttonberg
  module Middleware
    class Locales
      def initialize(app)
        @app = app
      end

      def call(env)
        name = case Gluttonberg.config.identify_locale
          when :subdomain
            # return the sub-domain
          when :prefix
            prefix = env['PATH_INFO']
            env['PATH_INFO'].gsub!(prefix, '')
            prefix
          when :domain
            env['SERVER_NAME']
        end

        if locale = Gluttonberg::Locale.find_by_name(name)
          env['gluttonberg.locale'] = locale
          env['gluttonberg.locale_name'] = name
        end

        @app.call(env)
      end
    end # Locales
  end # Middleware
end # Gluttonberg

