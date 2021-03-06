class ModelFactory::DSL::AssociationBlock
  
  module ModelCapture
    attr_accessor :models
    attr_accessor :association_extensions
    attr_accessor :klass
    attr_accessor :allow_use
    
    def create(*args, &block)
      attributes = args.extract_options!
      if name = args.first
        @models << @klass.factory.create(name, attributes, &block)
      else
        @models << ModelFactory::ProtoModel.new(klass, attributes, &block).create
      end
      
      @models.last
    end
    
    def use(factory_name)
      if allow_use
        @models << klass.factory.use(factory_name)
      else
        # TODO more informative message here
        raise ArgumentError, "use is not allowed here!"
      end
    end
    
    def remember_as(finder_name, model)
      @association_extensions << Module.new do
        define_method(finder_name) { model && model.reload }
      end
    end
    
    def model(ar_model)
      raise "ActiveRecord model expected, but got #{ar_model.class.name}" unless ar_model.is_a?(ActiveRecord::Base)
      @models << model
    end
  end
  
  include ModelFactory::DSL::Runner
  
  attr_reader :models
  attr_reader :association_extensions
  
  def initialize(klass, options = {:allow_use => true})
    @klass, @options = klass, options.dup
  end
  
  def run(&block)
    capsule = setup_and_run_block(block, ModelCapture) do |c|
      c.models = []
      c.association_extensions = []
      c.klass = @klass
      c.allow_use = @options[:allow_use] == true
    end
    @models = capsule.models
    @association_extensions = capsule.association_extensions
    self
  end
  
  def model
    models.first
  end
  
end
