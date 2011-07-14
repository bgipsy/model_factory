require 'spec_helper'

describe ModelFactory do
  
  before :each do
    [Book, Category, CoverType].each {|k| k.factory.clear!}
  end
  
  describe "instantiation" do
    
    before :each do
      Book.factory.define :generic do
        title 'The Bestselling Title'
        price 9.99
        pages 300
      end
    end
    
    it "should allow creating of new instances accoring to declaration" do
      @book = Book.factory.create :generic
      @book.new_record?.should be_false
      @book.title.should == 'The Bestselling Title'
      @book.price.should == 9.99
      @book.pages.should == 300
    end

    it "should allow overriding attributes on creation with hash syntax" do
      @book = Book.factory.create :generic, :title => 'Not so good name', :price => 4.95
      @book.title.should == 'Not so good name'
      @book.price.should == 4.95
    end

    it "should allow overriding attributes on creation with block syntax" do
      @book = Book.factory.create :generic do
        title '89 practical ways to title your book'
        price 6.95
      end
  
      @book.title.should == '89 practical ways to title your book'
      @book.price.should == 6.95
    end

    it "should create new instances on each call to `create`" do
      @book_a = Book.factory.create :generic
      @book_b = Book.factory.create :generic
      @book_a.should_not == @book_b
    end

    it "should allow reusing same instance with `use`" do
      @book_a = Book.factory.use :generic
      @book_b = Book.factory.use :generic
      @book_a.should == @book_b
      @book_a.price.should == 9.99
    end
    
    it "should allow [] syntax for reuse" do
      @book_a = Book.factory[:generic]
      @book_b = Book.factory[:generic]
      @book_a.should == @book_b
      @book_a.price.should == 9.99
    end
    
    it "should respect STI" do
      class CollectibleBook < Book
      end
      
      Book.factory.define :rare_book, :price => 100.00, :title => 'Rare Junk'
      CollectibleBook.factory.define :rare_book, :price => 1000.00, :title => 'Very Rare Collectible Junk'
      
      @book_a = Book.factory.create :rare_book
      @book_a.should be_instance_of(Book)
      @book_a.price.should == 100.00
      
      @book_b = CollectibleBook.factory.create :rare_book
      @book_b.should be_instance_of(CollectibleBook)
      @book_b.price.should == 1000.00
    end
    
    it "should handle mass assignment protection" do
      class SpecialBook < Book
        attr_accessible :title
      end
      
      SpecialBook.factory.define :generic do
        title 'The Title'
        price 24.95
      end
      
      @book = SpecialBook.factory.create(:generic)
      @book.should be_instance_of(SpecialBook)
      @book.price.should == 24.95
    end
    
    it "should respect foreign key NOT NULL constraints" do
      Comment.factory.define :generic, :body => 'Nice Book!'
      
      @book = Book.factory.create :generic do
        comments do
          create :generic
          create :generic
        end
      end
      
      @book.comments.size.should == 2
    end
    
  end
  
  describe "declarations" do
    
    it "should allow declarations with block syntax" do
      Book.factory.define :generic do
        title 'The Bestselling Title'
        price 9.99
      end
      
      Book.factory.create(:generic).new_record?.should be_false
    end
    
    it "should allow declarations with hash syntax" do
      Book.factory.define :generic, :title => 'The Bestselling Title', :price => 9.99
      Book.factory.create(:generic).new_record?.should be_false
    end
    
    it "should allow batch declarations with blocks" do
        Book.factory do
          
          define :bad_title do
            title 'Whatever'
          end
          
          define :good_title do
            title 'Whatever Comes First'
          end
          
        end

        Book.factory.create(:bad_title).new_record?.should be_false
        Book.factory.create(:good_title).new_record?.should be_false
      end
    
    it "should allow batch declarations with hashes" do
      Book.factory do
        define :bad_title, :title => 'Whatever'
        define :good_title, :title => 'Whatever Comes First'
      end
      
      Book.factory.create(:bad_title).new_record?.should be_false
      Book.factory.create(:good_title).new_record?.should be_false
    end
    
    it "should allow passing procs for generation of attribute values" do
      Book.factory.define :generic do
        title {|seq| "Bestseller # #{seq}"}
      end
      
      @book_1 = Book.factory.create :generic
      @book_2 = Book.factory.create :generic
      @book_1.title.should =~ /^Bestseller /
      @book_2.title.should =~ /^Bestseller /
      @book_1.title.should_not == @book_2.title
    end
    
  end
  
  describe "associations" do
    describe "for collections (has_many, has_and_belongs_to_many)" do
      
      it "should allow reusing instances for habtm associations" do
        Category.factory do
          define :fiction, :name => 'Fiction'
          define :business, :name => 'Business'
          define :self_help, :name => 'Self Help'
        end
        
        Book.factory.define :generic do
          title 'How to make $$'
          categories :self_help, :fiction
        end
        
        @book_a = Book.factory.create :generic, :title => 'How to wake up early'
        @book_b = Book.factory.create :generic, :title => 'How to give up coffee'
        
        @book_a.categories.should include(Category.factory[:fiction])
        @book_b.categories.should include(Category.factory[:fiction])
      end
      
      it "should create instances for has_many associations with symbol arguments syntax" do
        Comment.factory.define :generic, :body => 'Nice Book!'
        
        Book.factory.define :generic do
          title 'Whatever'
          comments :generic
        end
        
        @book_a = Book.factory.create :generic
        @book_b = Book.factory.create :generic
        
        @book_a.comments.should_not == @book_b.comments
      end
      
      it "should allow reusing instances for habtm associations with block syntax" do
        Category.factory do
          define :fiction, :name => 'Fiction'
          define :business, :name => 'Business'
          define :self_help, :name => 'Self Help'
        end
        
        Book.factory.define :generic do
          title 'Successful drinking habbits'
          categories do
            use :business
            use :self_help
          end
        end
        
        @book_a = Book.factory.create(:generic)
        @book_b = Book.factory.create(:generic)
        
        @book_a.categories.should include(Category.factory[:self_help])
        @book_b.categories.should include(Category.factory[:self_help])
      end
      
      it "should allow creation of instances for collections" do
        Book.factory.define :generic do
          title 'Life after death'
          categories do
            create :name => 'Esoteric' # hash syntax, or...
            create do                  # block syntax: effect is the same
              name 'Not Funny'
            end
          end
        end
        
        @book_a = Book.factory.create(:generic)
        @book_b = Book.factory.create(:generic)
        @book_a.categories.find_by_name('Esoteric').should_not == @book_b.categories.find_by_name('Esoteric')
      end
      
      it "should allow setting named finders for created instances" do
        Book.factory.define :generic do
          title 'Life after death'
          categories do
            remember_as :esoteric, create(:name => 'Esoteric')
            create :name => 'Funny'
          end
        end
        
        @book_a = Book.factory.create(:generic)
        @book_b = Book.factory.create(:generic)
        @book_a.categories.esoteric.name.should == 'Esoteric'
        @book_b.categories.esoteric.name.should == 'Esoteric'
        @book_a.categories.esoteric.should_not == @book_b.categories.esoteric
      end
      
      it "should not allow reusing instances for has_many associations" do
        Comment.factory.define :generic, :body => 'Nice Book!'
        
        Book.factory.define :generic do
          title 'Whatever'
          comments do
            use :generic
          end
        end
        
        lambda {
          Book.factory.create :generic
        }.should raise_exception(ArgumentError)
      end
      
      it "should handle collections passed in hash" do
        Comment.factory.define :generic, :body => 'Nice Book!'
        Book.factory.define :generic, :title => 'Whatever'
        
        @book = Book.factory.create :generic, :comments => [:generic, :generic, :generic]
        
        @book.comments.count.should == 3
      end
      
    end
    
    describe "for single models (belongs_to, has_one)" do
      
      it "should allow reusing instances for belongs_to" do
        CoverType.factory do
          define :paper_back, :name => 'Paper Back'
          define :hard_cover, :name => 'Hard Cover'
        end
        
        Book.factory.define :generic do
          title 'What comes next?'
          cover_type :paper_back
        end
        
        @book_a = Book.factory.create(:generic)
        @book_b = Book.factory.create(:generic)
        
        @book_a.cover_type.should == @book_b.cover_type
      end

      it "should allow creating instances" do
        CoverType.factory do
          define :paper_back, :name => 'Paper Back', :logo => 'paper_back.gif'
          define :hard_cover, :name => 'Hard Cover'
        end
        
        Book.factory.define :generic do
          title 'What comes next?'
          cover_type { create :paper_back, :name => 'Very Paper Back' } # referencing factory, and overriding name
        end
        
        @book_a = Book.factory.create(:generic)
        @book_b = Book.factory.create(:generic)
        
        @book_a.cover_type.should_not == @book_b.cover_type
        @book_a.cover_type.name.should == 'Very Paper Back'
        @book_a.cover_type.logo.should == 'paper_back.gif'
      end
      
      it "should not allow reusing instances for has_one" do
        Comment.factory.define :generic, :body => 'Nice Book!'
        
        Book.factory.define :generic do
          title 'Whatever'
          latest_comment { use(:generic) }
        end
        
        lambda {
          Book.factory.create :generic
        }.should raise_exception(ArgumentError)
      end
      
      it "should create instances for has_one by default" do
        Comment.factory.define :generic, :body => 'Nice Book!'
        
        Book.factory.define :generic do
          title 'Whatever'
          latest_comment :generic
        end
        
        @book_a = Book.factory.create :generic
        @book_b = Book.factory.create :generic
        
        @book_a.latest_comment.should_not == @book_b.latest_comment
      end
      
    end
  end
  
end
