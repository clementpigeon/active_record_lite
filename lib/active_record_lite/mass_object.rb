
class Object
 def self.new_attr_accessor(attr_name)
   define_method(attr_name) do
     syn_name = ('@' + attr_name.to_s).to_sym
      instance_variable_get(syn_name)
   end

   define_method("#{attr_name}=") do |value|
     syn_name = ('@' + attr_name.to_s).to_sym
     instance_variable_set(syn_name, value)
   end
 end
end


class MassObject

  def self.my_attr_accessible(*attributes)
    @attributes = []
    attributes.each do |attr|
      self.new_attr_accessor attr
      @attributes << attr
    end

  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def initialize(params = {})
    # p "#{self} initialize, @accessible attributes: ", self.class.accessible_attributes
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end

