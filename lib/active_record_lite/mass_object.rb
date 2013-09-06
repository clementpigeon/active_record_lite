
class Object
 def self.new_attr_accessor(attr_name)
   # puts "setting #{attr_name} as an attr_accessor on #{self}"

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
    @accessible_attributes = []
    attributes.each do |attr|
      self.new_attr_accessor attr
      @accessible_attributes << attr
    end

  end

  def self.accessible_attributes
    @accessible_attributes
  end

  def self.parse_all(results)
  end

  def initialize(params = {})
    # p "#{self} initialize, @accessible attributes: ", self.class.accessible_attributes
    params.each do |attr_name, value|
      if self.class.accessible_attributes.include?(attr_name.to_sym)
        self.send("#{attr_name.to_sym}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name.to_sym}"
      end
    end
  end
end

