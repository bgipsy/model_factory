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
  
  def instantiate(name, attributes = {}, &block)
    with_proto_model(name) {|proto| proto.instantiate(attributes, &block)}
  end
  
  alias_method :[], :use
  
  protected
  
  def with_proto_model(name, &block)
    proto_model = lookup(name.to_s)
    raise "Can't find model factory #{name.to_s} for #{@klass}!" if proto_model.nil?
    yield proto_model
  end
  
  # TODO consider: aren't we going in reverse direction here?
  # class SpecialBook < Book
  # class OtherSpecialBook < Book
  # 
  # SpecialBook.factory.define :x
  # OtherSpecialBook.factory.define :y
  # 
  # Book.factory.create :x => an instance of SpecialBook :x
  # Book.factory.create :y => an instance of OtherSpecialBook :y
  # 
  # works pretty much like AR STI: Book.find(id) => an instance of SpecialBook
  # 
  # (but requires traversing hierarchy in unusual direction, i.e. against 'super')
  
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
