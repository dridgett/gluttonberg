class BlogMigration < ActiveRecord::Migration 
  def self.up
    
    create_table :gb_blogs do |t|
      t.column :name, :string, :null => false
      t.column :slug, :string, :null => false
      t.column :description, :text
      t.column :user_id, :integer, :null => false
    end
    
    create_table :gb_articles do |t|
      t.column :title, :string, :null => false
      t.column :slug, :string, :null => false
      t.column :excerpt, :text
      t.column :body, :text
      t.column :blog_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end
    
  end

  def self.down
    drop_table :gb_articles
    drop_table :gb_blogs
  end
end
