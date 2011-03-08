module Gluttonberg
  class Page < ActiveRecord::Base
    has_many :localizations, :class_name => "Gluttonberg::PageLocalization"
  end
end

