# Rationale

Just as other factory components, model_factory is designed to be used in test environment for populating database tables with records within Test::Unit, RSpec or any other kind of test suite.

Rails fixtures are great and should be preferred for simple cases. But when domain starts gaining complexity, desire to build more self-contained tests may arise. And that's when search for balance between shared set of commonly used fixtures and example-specific instances starts. ModelFactory can't help in finding such balance, as it's always very context sensitive. However it can offer some tools for keeping implementation explicit and expressive.

Here are the primary drivers of design for this particular ModelFactory library:

 * Factory definition should look 'very declarative', imperative constructs should be avoided if possible.
 * Factory definitions should be scoped by model classes, class binding should be explicitly visible in syntax constructs for instantiation and declaration.
 * All blocks should be evaluated when factory model is instantiated, no database manipulation should occur at declaration step.
 * Library should handle ActiveRecord associations in declarative way, and there should be a good way to build models with complex relationships in both bottom-up and top-to-bottom fashion, whichever makes most sense in particular case.
 * It should be possible to have 'singleton' instances, i.e. link against same instances of model 'Country' from multiple factory generated instances of model 'Address'


# Model Instantiation

## Create vs Use

Let's start looking at syntax from the perspective of instantiating factory models. Suppose we have Book model, and a factory called `:generic` was declared for it. Here's how we can start getting instances of Book:

    @book_1 = Book.factory.create :generic
    @book_2 = Book.factory.create :generic

Model.factory.create will spawn new instance of Model on each call. Each such instance will have attributes and associations set up according to `:generic` factory declaration.

    @book_1 = Book.factory.use :generic
    @book_2 = Book.factory.use :generic

Each call to `Model.factory.use` will return the same 'singleton' instance of Model. Such instance will be constructed on first call to `use` and will have attributes and associations set up according to factory declaration found by name `:generic`. So in the example above `@book_1 == @book_2`.

    @book = Book.factory.use :generic
    @book = Book.factory[:generic]

The `[]` syntax is a shorthand for `use`, so these two lines above are equivalent.

All model factories can be instantiated at once with `Model.factory.all`. Let's suppose that we have `CoverType` model with two factories declared: `:hard_cover` and `:paper_back`

    @cover_types = CoverType.factory.all

will produce effect similar to:

    @cover_types = [CoverType.factory[:hard_cover], CoverType.factory[:paper_back]]


## Overriding Attributes

When creating instances, factory defined attributes can be overridden. It can be done with hash or block syntax:

    @book = Book.factory.create(:generic, :title => 'Another Bestselling Title')
    
    @book = Book.factory.create :generic do
      title 'Another Bestselling Title'
      price 4.95
    end

Block and hash syntax for overrides is very similar to factory declaration syntax.

# Declaring Factories

Factories are scoped by model, so it's possible to have distinct factories with same name for different models. Factories can be defined with hash or block syntax.

    Book.factory.define(:generic, :title => 'Very Nice Book', :price => 12.99)
    
    Book.factory.define(:funny_tales) do
      title 'Funny Tales'
      price 9.95
    end

Factories can be defined in batches, the following syntax can be used to produce more compact declarations:

    Book.factory do
      define :generic, :title => 'Very Nice Book', :price => 19.99
      define :funny_tales, :title => 'Funny Tales', :price => 9.95
      define :boring, :title => '101 smart was to come up with boring NDA friendly examples', :price => 3.95
    end

## Blocks And Attributes

Blocks can be used for complex cases when attribute value requires calculation, or when association is polymorphic. Blocks may accept argument, factory passes sequence string to help fill in unique attributes:

    Book.factory.define(:generic) do
      title {|sequence| "Book #{sequence}"}
      price 9.95
    end
    
    Comment.factory.define(:positive) do
      comment 'Nice Book'
      rating 10
      author { GuestUser.use(:happy_fan) }
    end

## Associations

Let's Suppose we have models Book, Category and CoverType with relationships described below:

    class Book < ActiveRecord::Base
      belongs_to              :cover_type
      has_and_belongs_to_many :categories
      has_many                :comments
    end
    
    class CoverType < ActiveRecord::Base
      has_many :books
    end
    
    class Comment < ActiveRecord::Base
      belongs_to :book
    end
    
    class Category < ActiveRecord::Base
      has_and_belongs_to_many :books
    end

For collection associations, corresponding models can be created in-place, created from factories, created from factories with overrides or referenced as singleton models:

    # below :fiction and :self_help are referenced with `use`:
    Book.factory.define :generic do
      title 'Smart Title'
      price 19.99
      categories :fiction, :self_help
    end
    
    # and here each book generated with this factory gets own copies of categories:
    Book.factory.define :generic do
      title 'Smart Title'
      price 19.99
      categories do
        create :fiction
        create :self_help
      end
    end
    
    # reference strategy can be controller on per-model basis, and `create` can take attribute overrides:
    Book.factory.define :generic do
      title 'Smart Title'
      price 19.99
      categories do
        create :fiction, :name => 'Schöne Literatur'
        use :self_help
      end
    end

It's possible to set up dedicated accessor for particular instance inside of collection association. Accessor is defined as an association extension for instances created by corresponding factory, so you don't step into interference with regularly created models or models created by other factories:

    Book.factory.define :generic do
      title 'Smart Title'
      price 19.99
      categories do
        remember_as :fiction, create(:fiction,  :name => 'Schöne Literatur')
        create :self_help
      end
    end
    
    @book = Book.factory.create(:generic)
    @book.categories.fiction.name == 'Schöne Literatur'

