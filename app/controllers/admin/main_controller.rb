class Admin::MainController < ApplicationController
  include Gluttonberg::AdminMixin

  def index
    render
  end
end
