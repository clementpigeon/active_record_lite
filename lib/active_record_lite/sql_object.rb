require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'
require 'debugger'

class SQLObject < MassObject

  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    return @table_name if @table_name
    self.to_s.underscore.pluralize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{table_name}
    SQL

    self.parse_all(rows)
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
    attributes = self.class.attributes

    attr_list = attributes.join(', ')

    values = attributes_values

    question_marks = Array.new(attributes.count) {'?'}.join(', ')

    result = DBConnection.execute(<<-SQL, *values)
      INSERT INTO #{self.class.table_name} (#{attr_list})
      VALUES (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    attributes = self.class.attributes

    values = attributes_values

    set_line = attributes.map{ |attr| "#{attr} = ?" }.join(', ')

    result = DBConnection.execute(<<-SQL, *values)
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = #{id}
    SQL
  end

  def attributes_values
    self.class.attributes.map { |attr| self.send(attr) }
  end

end
