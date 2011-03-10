module Gluttonberg
  module Admin
    module Content
      class MainController < ApplicationController
        include Gluttonberg::AdminControllerMixin
        layout 'gluttonberg'

        def index
        end
      
      end #class
    end #content
  end #admin
end #GB
