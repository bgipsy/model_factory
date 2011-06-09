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
