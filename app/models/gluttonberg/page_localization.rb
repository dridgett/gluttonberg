module Gluttonberg
  class Localization < ActiveRecord::Base
    belongs_to :page, :class_name => "Gluttonberg::Page"
  end
end

