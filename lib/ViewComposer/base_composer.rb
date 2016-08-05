require 'json'
class BaseComposer
  class << self
    attr_accessor :_attributes
  end
  self._attributes = []

  def initialize(model:, composable_objects: [] )
    @model = model
    @json_hash = {}

    @parent_methods = self.class.superclass.instance_methods(false)
    @composer_methods = self.class.instance_methods(false)
    @dont_redefine = @parent_methods + @composer_methods
    @_attrs = self.class._attributes
    set_attributes
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
  end

private

  def methods_to_hash
    methods = self.class.instance_methods(false) - [:to_json, :hash_attrs]
    methods.each do |method|
      @json_hash[method] = self.send(method)
    end
  end

  def set_attributes
    defineable_methods = @_attrs - @dont_redefine
    #puts "#{self}: #{defineable_methods}"
    define_methods(defineable_methods, @model)
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
        #puts method_owner.send(attr)
        method_owner.send(attr)
      end
    end
  end

end
