class ModelFactory::Factory
  
  def initialize(klass)
    @klass = klass
    @map = Hash.new
  end
  
  def clear!
    @map.clear
  end
  
  def define(name, attributes = {}, &block)
    @map[name.to_s] = ModelFactory::ProtoModel.new(@klass, attributes, &block)
  end
    
  def create(name, attributes = {}, &block)
    with_proto_model(name) {|proto| proto.create(attributes, &block)}
  end
  
  def use(name)
    with_proto_model(name) {|proto| proto.use}
  end
  
  alias_method :[], :use
  
  protected
  
  def with_proto_model(name, &block)
    proto_model = lookup(name.to_s)
    raise "Can't find model factory #{name.to_s} for #{@klass}!" if proto_model.nil?
    yield proto_model
  end
  
  def lookup(name)
    if @map[name]
      @map[name]
    else
      # Descendant classes should be loaded for this to work
      @klass.descendants.each do |klass|
        proto_model = klass.factory.lookup(name)
        return proto_model if proto_model
      end
      
      nil
    end
  end

end
