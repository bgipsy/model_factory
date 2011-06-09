class ModelFactory::CollectionAssociation < ModelFactory::Member
  
  def initialize(reflection, values, &block)
    @reflection, @values, @block = reflection, values, block
  end
  
  def to_value
    if @block
      runner.models
    else
      @values.map do |v|
        v.is_a?(Symbol) ? @reflection.klass.factory.use(v) : v
      end
    end
  end
  
  def to_association_extensions
    if @block
      runner.association_extensions
    else
      []
    end
  end
  
  private
  
  def runner
    @runner ||= ModelFactory::DSL::AssociationBlock.new(@reflection.klass).run(&@block)
  end
  
end
