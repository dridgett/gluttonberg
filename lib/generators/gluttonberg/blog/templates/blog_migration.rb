class BlogMigration < ActiveRecord::Migration 
  def self.up
    
    create_table :gb_blogs do |t|
      t.string :name, :null => false
      t.string :slug, :null => false
      t.text :description
      t.integer :user_id, :null => false
      t.column :state , :string
      t.timestamps
    end
    
    create_table :gb_articles do |t|
      t.string :title, :null => false
      t.string :slug, :null => false
      t.text :excerpt
      t.text :body
      t.integer :blog_id, :null => false
      t.integer :user_id, :null => false
      t.integer :author_id, :null => false      
      t.integer :featured_image_id
      t.column :state , :string
      t.timestamps
    end
    
    create_table :gb_comments do |t|
      t.text :body
      t.string :author_name
      t.string :author_email
      t.string :author_website
      t.references :commentable, :polymorphic => true
      t.integer :author_id
      t.boolean :moderation_required, :default => true
      t.boolean :approved, :default => false
      t.timestamps
    end
    
  end

  def self.down
    drop_table :gb_comments
    drop_table :gb_articles
    drop_table :gb_blogs
  end
end
