class ModelFactory::DSL::AttributeHandler

  module AttributeCapture
    attr_accessor :proto_model
    attr_reader :attributes

    def add_attribute(name, args, &block)
      @attributes ||= {}
      @attributes[name.to_s] = proto_model.new_member(name, args, &block)
    end
    
    def method_missing(name, *args, &block)
      add_attribute(name.to_s, args, &block)
    end
  end
  
  include ModelFactory::DSL::Runner
  
  def initialize(proto_model)
    @proto_model = proto_model
  end
  
  def run(attributes, &block)
    @attributes = Hash[attributes.map {|name, value| [name.to_s, @proto_model.new_member(name, [value])]}]
    
    if block_given?
      capsule = setup_and_run_block(block, AttributeCapture) {|c| c.proto_model = @proto_model}
      @attributes.merge!(capsule.attributes || {})
    end
    
    self
  end
  
  def to_attributes
    Hash[(@attributes || {}).map {|k, v| [k, v.to_value]}]
  end
  
  def to_association_extensions
    Hash[(@attributes || {}).map {|k, v| [k, v.to_association_extensions]}]
  end

end
