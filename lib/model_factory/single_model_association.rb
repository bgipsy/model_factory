class ModelFactory::SingleModelAssociation < ModelFactory::Member
  
  def initialize(reflection, value, &block)
    @reflection, @value, @block = reflection, value, block
  end
  
  def to_value
    if @block
      ModelFactory::DSL::AssociationBlock.new(@reflection.klass).run(&@block).model
    elsif @value.is_a?(Symbol)
      @reflection.klass.factory.use(@value)
    else
      @value
    end
  end
  
end
