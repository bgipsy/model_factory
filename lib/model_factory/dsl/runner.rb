module ModelFactory::DSL::Runner

  def run_block(*dsl_modules, &block)
    # TODO use blank state ?
    capsule = Object.new
    capsule.extend(*dsl_modules.push(Module.new { define_method :run!, &block }))
    capsule.run!
    capsule
  end
  
  def setup_and_run_block(dsl_block, *dsl_modules, &block)
    # TODO use blank state ?
    capsule = Object.new
    capsule.extend(*dsl_modules.push(Module.new { define_method :run!, &dsl_block }))
    yield capsule if block_given?
    capsule.run!
    capsule
  end

end
