class Superclass
  def initialize
    p "#{self}"
  end

end

class Subclass < Superclass

end

class Sub_sub_class < Superclass

end

superclass_object = Superclass.new
subclass_object = Subclass.new
sub_sub_object = Sub_sub_class.new