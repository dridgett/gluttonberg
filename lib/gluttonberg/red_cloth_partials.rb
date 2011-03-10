#
# Red Cloth Partials
#
# This module adds support to access Merb Parts from within Gluttonberg
# RichTextContent Sections.
#
# To enable a merb Part to be available to Gluttonberg you need to use the
# partials class method. See the example below.
module Gluttonberg
  module RedClothPartials
    module PartsControllerMixin
      @@partials_definition_list = {}

      def self.included(klass)
        klass.class_eval do

          # register this PartsContollers actions with a specific route. This is a route
          # used in the RedCloth extension to embed partials data into a
          # page section using RedCloth
          #
          #   class Films < PartController
          #     partials :summary, :recent
          #     partial_route :movies
          #
          #     def summary(id)
          #       "<div class='film'>#{id}</div>"
          #     end
          #
          #     def recent
          #       id = Film.most_recent
          #       summary(id)
          #     end
          #
          #   end
          #
          #   callable in texile like so:
          #
          #   irb> RedCloth.new('blah blah {{movies/summary/4}} blah blah').to_html
          #   > "<p>blah blah <div class='film'>4</div> blah blah</p>"
          #
          #   irb> RedCloth.new('blah blah {{movies/recent}} blah blah').to_html
          #   > "<p>blah blah <div class='film'>78</div> blah blah</p>"
          #
          def self.partials(*actions)

            routedef = @@partials_definition_list[self]
            routedef = RouteDefinition.new(self) unless routedef

            actions.each do |action|
              routedef.add_action(action)
            end
          end

          # see example for partials()
          def self.partial_route(route_name)
            routedef = @@partials_definition_list[self]
            routedef = RouteDefinition.new(self) unless routedef

            routedef.controller_route_name = route_name
          end
        end
      end

    end

    class RouteDefinition
      attr_accessor :controller_route_name
      attr_accessor :controller
      attr_accessor :actions

      def initialization(cont)
        @actions = []
        self.controller = cont
        self.controller_route_name = cont.to_s
      end

      def add_action(action)
        @actions << action
      end
    end

    class Renderer

      # Called within a view or controller action to process
      # the string data in "content". If "content" contains
      # partial calls they are processed and preplaced with
      # the results of those partials.
      #
      def self.render(controller, content)

        #TODO: Parse content and replace occurancesof {{x/y/z}} with the
        #      merb parts result within the {{ }}
        #      lookup the correct part to use by looking in the
        #      PartsControllerMixin.@@partials_definition_list for the
        #      matching entry


        content
      end
    end
  end
end
