module Gluttonberg
  module Admin
    class MainController < ApplicationController
      include Gluttonberg::AdminControllerMixin
      layout 'gluttonberg'

      unloadable
      
      def index
      end
      
      def show
      end
      
    end
  end
end
