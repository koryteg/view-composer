require 'json'
EXCLUDED_METHODS = [:to_json, :hash_attrs, :set_inherited_methods_list]
class BaseComposer
  class << self
    attr_accessor :_attributes, :_inherited_methods
  end
  self._attributes = []
  self._inherited_methods = []

  def initialize(model:, composable_objects: [] )
    set_inherited_methods_list
    @model = model
    @json_hash = {}
    @_attrs = self.class._attributes
    @inherited_methods = self.class._inherited_methods
    @instance_methods = self.class.instance_methods(false)
    set_attributes_methods
    setup_comp_objs(composable_objects)
    methods_to_hash
  end

  def hash_attrs
    @json_hash
  end

  def to_json
    @json_hash.to_json
  end

  def self.attributes(*attrs)
    Array(attrs).each {|attr| self._attributes << attr}
  end

  def self.inherited(base)
    super
    base._attributes = self._attributes.dup
    base._inherited_methods = self._inherited_methods.dup
  end

private

  def get_all_methods
    (@_attrs + @inherited_methods + @instance_methods).uniq
  end

  def set_inherited_methods_list
    _methods = self.class.superclass.instance_methods(false) - EXCLUDED_METHODS
    self.class._inherited_methods += _methods
  end

  def methods_to_hash
    methods = get_all_methods - EXCLUDED_METHODS
    methods.each do |method|
      @json_hash[method] = self.send(method)
    end
  end

  def set_attributes_methods
    define_methods(definable_methods, @model)
  end

  def definable_methods
    m = @_attrs - @inherited_methods
    m - @instance_methods
  end

  def setup_comp_objs(comp_objs_array)
    @comp_objs = comp_objs_array.map do |obj|
      object_instance = obj.new(@model)
      define_methods(obj.instance_methods(false), object_instance)
      return object_instance
    end
  end

  def define_methods(method_names, method_owner)
    method_names.each do |attr|
      self.class.send(:define_method, attr) do
        method_owner.send(attr)
      end
    end
  end

end
