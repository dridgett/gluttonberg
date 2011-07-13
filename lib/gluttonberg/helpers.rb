helpers = File.join(Pathname(__FILE__).dirname.expand_path, "helpers")
require File.join(helpers, "content")
require File.join(helpers, "asset_library")
require File.join(helpers, "public")
require File.join(helpers, "admin")
require File.join(helpers, "form_builder")

module Gluttonberg
  # A whole heaping helping of helpers for both the administration back-end and
  # the public views.
  module Helpers
    # Mixes all the helpers into the GlobalHelpers module. Slighly messy, but
    # hey it works.
    def self.setup
      [AssetLibrary, Admin, Public, Content].each do |helper|
        ActionView::Helpers.send(:include, helper)
      end
    end
  end
end
