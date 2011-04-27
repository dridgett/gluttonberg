module Gluttonberg
  module Middleware
    class Honeypot

      def initialize(app, field_name)
        @app = app
        @field_name = field_name
      end

      def call(env)
        form_hash = env["rack.request.form_hash"]

        if form_hash && form_hash[@field_name] =~ /\S/
          [200, {'Content-Type' => 'text/html', "Content-Length" => "0"}, []]
        else
          @app.call(env)
        end
      end

    end
  end # Middleware
end # Gluttonberg

