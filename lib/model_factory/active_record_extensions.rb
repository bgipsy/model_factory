module ModelFactory::ActiveRecordExtensions
    
  def factory(&block)
    factory = read_inheritable_attribute(:model_factory)
    if factory
      factory
    else
      factory = ModelFactory::Factory.new(self)
      write_inheritable_attribute(:model_factory, factory)
    end
    
    if block_given?
      factory.instance_eval(&block)
    else
      factory
    end
  end
    
end

ActiveRecord::Base.extend(ModelFactory::ActiveRecordExtensions)
