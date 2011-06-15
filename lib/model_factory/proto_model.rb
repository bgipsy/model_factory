class ModelFactory::ProtoModel

  def initialize(klass, attributes, &block)
    @klass, @attributes, @block = klass, attributes.stringify_keys, block
  end
  
  def create(attributes = {}, &block)
    definition = ModelFactory::DSL::AttributeHandler.new(self).run(@attributes, &@block)
    overrides = ModelFactory::DSL::AttributeHandler.new(self).run(attributes, &block)
    
    model = @klass.new
    assign_attributes(model, definition.to_attributes.merge(overrides.to_attributes))
    model.save!
    
    add_association_extensions(model, definition.to_association_extensions.merge(overrides.to_association_extensions))
    
    model
  end
  
  def new_member(name, args, &block)
    reflection = @klass.reflect_on_association(name.to_sym)
    
    if reflection.nil?
      ModelFactory::Attribute.new(args.first, &block)
    elsif reflection.collection?
      ModelFactory::CollectionAssociation.new(reflection, args, &block)
    else
      ModelFactory::SingleModelAssociation.new(reflection, args.first, &block)
    end
  end
  
  def use
    if @the_instance && @the_instance.reload
      @the_instance
    else
      @the_instance = create
    end
  end
  
  private
  
  def add_association_extensions(model, extensions)
    extensions.each do |name, modules|
      proxy = model.send(name)
      modules.each {|m| proxy.extend(m)}
    end
  end
  
  def assign_attributes(model, attributes)
    attributes.each_pair do |name, value|
      model.send("#{name}=", value)
    end
  end
  
end
