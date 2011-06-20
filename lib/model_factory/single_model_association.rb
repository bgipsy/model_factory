class ModelFactory::SingleModelAssociation < ModelFactory::Member
  
  def initialize(reflection, value, &block)
    @reflection, @value, @block = reflection, value, block
  end
  
  def to_value
    if @block
      ModelFactory::DSL::AssociationBlock.new(@reflection.klass, :allow_use => allow_use?).run(&@block).model
    elsif @value.is_a?(Symbol)
      allow_use? ? @reflection.klass.factory.use(@value) : @reflection.klass.factory.instantiate(@value)
    else
      @value
    end
  end
  
  def allow_use?
    @reflection.macro != :has_one
  end
  
end
