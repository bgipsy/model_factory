class ModelFactory::Attribute < ModelFactory::Member
  
  def initialize(value = nil, &block)
    @value, @block = value, block
  end
  
  def to_value
    if @block
      @block.call seq_value
    else
      @value
    end
  end
  
  private
  
  def seq_value
    @@seq_value ||= '0000'
    @@seq_value = @@seq_value.succ
  end
  
end
