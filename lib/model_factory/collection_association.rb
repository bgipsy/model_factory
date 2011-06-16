class ModelFactory::CollectionAssociation < ModelFactory::Member
  
  def initialize(reflection, values, &block)
    @reflection, @values, @block = reflection, values, block
  end
  
  def to_value
    if @block
      runner.models
    elsif allow_use?
      @values.map do |v|
        v.is_a?(Symbol) ? @reflection.klass.factory.use(v) : v
      end
    else
      @values.map do |v|
        v.is_a?(Symbol) ? @reflection.klass.factory.create(v) : v
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
    @runner ||= ModelFactory::DSL::AssociationBlock.new(@reflection.klass, :allow_use => allow_use?).run(&@block)
  end
  
  def allow_use?
    @reflection.macro != :has_many
  end
  
end
