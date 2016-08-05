require 'json'
class BaseComposer
  @attributes ||= []
  def initialize(model:, composable_objects: [] )
    #self.class.attributes
    @model = model
    @composer_methods = self.class.instance_methods(false)
    @json_hash = {}
    set_attributes(self.class.get_attributes)
    setup_comp_objs(composable_objects)
    methods_to_hash
  end

  def hash_attrs
    @json_hash
  end

  def to_json
    @json_hash.to_json
  end

  def self.attributes(*attributes)
    @attributes = attributes
  end

  def self.get_attributes
    @attributes || []
  end

  def self.inherited(base)
    super
    #puts "#{base}: #{get_attributes}"
  end

private

  def define_methods(method_names, method_owner)
    method_names.each do |attr|
      self.class.send(:define_method, attr) do
        method_owner.send(attr)
      end
    end
  end

  def methods_to_hash
    methods = self.class.instance_methods(false) - [:to_json, :hash_attrs]
    methods.each do |method|
      @json_hash[method] = self.send(method)
    end
  end

  def set_attributes(attrs)
    defineable_methods = attrs - @composer_methods
    define_methods(defineable_methods, @model)
  end

  def setup_comp_objs(comp_objs_array)
    @comp_objs = comp_objs_array.map do |obj|
      object_instance = obj.new(@model)
      define_methods(obj.instance_methods(false), object_instance)
      return object_instance
    end
  end

end
