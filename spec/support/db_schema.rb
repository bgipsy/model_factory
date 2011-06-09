DB_FILE = File.join(File.dirname(__FILE__), '..', 'test.db')

TEST_DB = {
  :adapter  => 'sqlite3',
  :database => DB_FILE
}

ActiveRecord::Base.establish_connection(TEST_DB)

class CreateTestSchema < ActiveRecord::Migration
  def self.prepare_database
    File.unlink(DB_FILE) rescue nil
    migrate(:up)
  end
  
  def self.up
    create_table :categories do |t|
      t.string :name
    end
    
    create_table :cover_types do |t|
      t.string :name
      t.string :logo
    end
    
    create_table :books do |t|
      t.string     :title, :null => false
      t.float      :price
      t.integer    :pages
      t.references :cover_type
    end
    
    create_table :books_categories, :id => false do |t|
      t.references :book
      t.references :category
    end
    
    create_table :comments do |t|
      t.references :book
      t.text :body
    end
  end

  def self.down
    drop_table :books
    srop_table :books_categories
    drop_table :cover_types
    drop_table :categories
  end
end
