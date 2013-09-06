
class Object
 def self.new_attr_accessor(attr_name)
   puts "setting #{attr_name} as an attr_accessor"

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

class Cat
   new_attr_accessor :first_name
end
