class AddPageLocalizations < ActiveRecord::Migration
  def self.up
    create_table :gluttonberg_page_localizations do |t|
      t.string :name
      t.string :navigation_label
      t.string :slug
      t.string :path
    end
  end

  def self.down
    drop_table :gluttonberg_page_localizations
  end
end
