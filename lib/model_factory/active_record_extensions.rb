module ModelFactory::ActiveRecordExtensions
    
  def factory(&block)
    @factory ||= ModelFactory::Factory.new(self)
    
    if block_given?
      @factory.instance_eval(&block)
    else
      @factory
    end
  end
    
end

ActiveRecord::Base.extend(ModelFactory::ActiveRecordExtensions)
