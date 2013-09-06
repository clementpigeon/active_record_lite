require 'active_record_lite'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
cats_db_file_name =
  File.expand_path(File.join(File.dirname(__FILE__), "cats.db"))
DBConnection.open(cats_db_file_name)

class Cat < SQLObject
  set_table_name("cats")
  my_attr_accessible(:id, :name, :owner_id)
end

class Human < SQLObject
  set_table_name("humans")
  my_attr_accessible(:id, :fname, :lname, :house_id)
end

# p Human.find(1)
# p Cat.find(1)
# p Cat.find(2)

# p Human.all


# c = Cat.new(:name => "Gizmo", :owner_id => 1)
# #
# # puts c
# # p Cat.all
#
# print Cat.all
# cat1 = Cat.find(1)
# cat1.name = 'dinner'
# cat1.update
# p cat1
# #
#
# c.update
# p Cat.all
p cat1 = Cat.all.first
cat1.owner_id = 92
cat1.save
# p cat1
p Cat.all.first

p Cat.all.last
new_cat = Cat.new(name: 'bob', owner_id: 91)
new_cat.save
p Cat.all.last