require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'
require 'debugger'



class SQLObject < MassObject

  def self.set_table_name(table_name)
    # let the user specify the table on which to execute queries for this clas.
    # We should store the table name in a class instance variable.
    @table_name = table_name
  end

  def self.table_name
    if @table_name
      return @table_name
    else
      model_name = ActiveSupport::Inflector.underscore(self.superclass.to_s)
      model_name = ActiveSupport::Inflector.pluralize(model_name)
      return model_name
    end

  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{table_name}
    SQL
    rows.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
    SELECT *
    FROM #{table_name}
    WHERE #{table_name}.id = ?
    SQL
    return nil if result.empty?
    self.new(result.first)
  end

  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  private

  def create
    attributes = self.class.accessible_attributes
    attributes = attributes.dup
    attributes.delete(:id)
    attr_list = attributes.join(', ')
    question_marks = Array.new(attributes.count) {'?'}.join(', ')
    values_list = attributes.map { |attr| self.send(attr) }

    result = DBConnection.execute(<<-SQL, *values_list)
      INSERT INTO #{self.class.table_name} (#{attr_list})
      VALUES (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    # debugger
    attributes = self.class.accessible_attributes
    set_line = attributes.map{ |attr| "#{attr} = ?" }.join(', ')
    values_list = attributes.map { |attr| self.send(attr) }

    query = "UPDATE #{self.class.table_name} SET " + set_line + " WHERE id = #{id}"

    result = DBConnection.execute(query, *values_list)
  end



  def attribute_values
  end
end
