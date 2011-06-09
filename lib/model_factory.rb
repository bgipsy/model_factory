require 'active_record'

$LOAD_PATH << File.dirname(__FILE__)

module ModelFactory
  module DSL; end
end

require 'model_factory/factory'
require 'model_factory/proto_model'
require 'model_factory/member'
require 'model_factory/attribute'
require 'model_factory/single_model_association'
require 'model_factory/collection_association'
require 'model_factory/active_record_extensions'

require 'model_factory/dsl/runner'
require 'model_factory/dsl/association_block'
require 'model_factory/dsl/attribute_handler'
