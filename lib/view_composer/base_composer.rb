require 'json'
EXCLUDED_METHODS = [:to_json, :hash_attrs,
                    :set_inherited_methods_list,
                    :instance_methods,
                    :inherited_methods,
                    :attributes,
                    :instance_attributes,
                    :set_model_methods,
                    :new_model_methods,
                    :definable_model_methods,
                    :super_model_methods]
module ViewComposer
  class BaseComposer
    class << self
      attr_accessor :_attributes,
      :_instance_attrs,
      :_model_methods,
      :_instance_defined_methods,
      :_inherited_methods
    end
    self._attributes = []
    self._instance_attrs = []
    self._inherited_methods = []

    def initialize(model:, composable_objects: [] )
      @model = model
      @json_hash = {}

      set_model_methods
      set_attributes_methods
      setup_comp_objs(composable_objects)
      methods_to_hash
    end

    def self.attributes(*attrs)
      self._instance_attrs = attrs
      Array(attrs).each {|attr| self._attributes << attr}
    end

    def self.inherited(base)
      super
      base._attributes = self._attributes.dup
    end

    def hash_attrs
      @json_hash
    end

    def to_json
      @json_hash.to_json
    end

    private

    def set_model_methods
      new_model_methods = attributes - self.methods
      set_model_methods_array(new_model_methods)
    end

    def attributes
      @attributes ||= self.class._attributes
    end

    def instance_methods
      @instance_methods ||= self.class.instance_methods(false)
    end

    def get_all_methods
      (attributes + instance_methods).uniq
    end

    def methods_to_hash
      methods = get_all_methods - EXCLUDED_METHODS
      methods.each do |method|
        @json_hash[method] = self.send(method)
      end
    end

    def definable_model_methods
      []
    end

    def set_model_methods_array(new_model_methods)
      dup_of_methods = definable_model_methods.dup
      self.class.send(:define_method, "definable_model_methods") do
        (dup_of_methods + new_model_methods).uniq
      end
    end

    def set_attributes_methods
      define_methods(definable_model_methods, @model)
    end

    def setup_comp_objs(comp_objs_array)
      @comp_objs = comp_objs_array.map do |obj|
        object_instance = obj.new(@model)
        define_methods(obj.instance_methods(false), object_instance)
        return object_instance
      end
    end

    def define_methods(method_names, method_owner)
      method_names.uniq.each do |attr|
        send(:define_singleton_method, attr) do
          method_owner.send(attr)
        end
      end
    end
  end
end
