class AddPages < ActiveRecord::Migration
  def self.up
    create_table :gluttonberg_pages do |t|
      t.integer :parent_id
      t.string :name
      t.string :navigation_label
      t.string :slug
      t.string :description_name
      t.boolean :home, :default => false
    end
  end

  def self.down
    drop_table :gluttonberg_pages
  end
end
